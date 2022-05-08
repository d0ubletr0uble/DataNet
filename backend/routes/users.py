import http
import json
from typing import List, Any

import cv2
from fastapi import APIRouter, Request, Form
from pydantic import BaseModel

from backend.ai_models import detector
from backend.db import milvus
from backend.db import mongo
from backend.db import bucket
from backend.utils import utils

model = detector.instance
milvus = milvus.instance
mongodb = mongo.instance.db
s3 = bucket.instance.client

router = APIRouter()


class FaceList(BaseModel):
    class FaceInput(BaseModel):
        face: str
        embedding: List[float]
        data: dict

    faces: List[FaceInput]


class UsersResponse(BaseModel):
    users: List[dict]

    class Config:
        schema_extra = {
            'example': {
                'users': [
                    {'_id': '432274227563069451', 'name': 'John Smith', 'age': 20},
                    {'_id': '562627439967832726', 'type': 'student', 'modules': ['P1456235', 'P1655578']},
                    {'_id': '465612315423184238', 'name': 'Foo Bar', 'vip': True},
                ]
            }
        }


@router.post('/search', status_code=http.HTTPStatus.OK, response_model=UsersResponse)
async def list_users(req: Request):
    query = await req.json()
    users = mongodb.users.find(query)
    return {'users': list(users)}


@router.post('', status_code=http.HTTPStatus.CREATED)
async def upload(req: FaceList):
    if len(req.faces) == 0:
        return None

    faces = [utils.base64_to_cv2(f.face) for f in req.faces]

    # data persistence
    _, ids = milvus.milvus.insert(collection_name='users', records=[f.embedding for f in req.faces])
    milvus.milvus.flush(['users'])

    mongodb.users.insert_many([
        {'_id': str(pk), **f.data}
        for f, pk
        in zip(req.faces, ids)
    ])

    for face, key in zip(faces, ids):
        s3.put_object(
            ACL='public-read',
            Bucket='users',
            Key=f'{key}.jpg',
            Body=cv2.imencode('.jpg', cv2.cvtColor(face, cv2.COLOR_RGB2BGR))[1].tostring(),
        )

    return None


@router.put('/{user_id}', status_code=http.HTTPStatus.OK)
async def edit_user(user_id: str, req: Request):
    data = await req.json()
    data['_id'] = user_id

    mongodb.users.replace_one(
        {'_id': user_id},
        data
    )

    return data


class FindInput(BaseModel):
    embedding: List[float]


# todo api doc
@router.post('/find', status_code=http.HTTPStatus.OK)
async def edit_user(req: FindInput):
    _, results = milvus.milvus.search(
        collection_name='users',
        query_records=[req.embedding],
        top_k=3,
    )

    quantify = lambda x: 'Strong' if x < 100 else 'Medium' if x < 150 else 'Weak'

    return {'users': [
        {
            '_id': str(id),
            'similarity': quantify(dis),
            'data': mongodb.users.find_one({'_id': str(id)}),  # NOTE: performance
        }
        for dis, id in zip(results.distance_array[0], results.id_array[0])
    ]}


@router.post('/batch-edit')
def upload(image: str = Form(...), data: str = Form(...)):
    img = utils.base64_to_cv2(image)
    _, prepared_faces = model.get_faces(img)

    embeddings = model.get_embeddings(prepared_faces)

    _, results = milvus.milvus.search(
        collection_name='users',
        query_records=embeddings,
        top_k=1,
    )

    ids = [str(id[0]) for id, dis in zip(results.id_array, results.distance_array) if dis[0] < 100]

    mongodb.users.update_many(
        {'_id': {'$in': ids}},
        {'$set': json.loads(data)}
    )

    return {'updated': len(ids)}
