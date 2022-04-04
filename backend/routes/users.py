import http
import json
from typing import List, Any

import cv2
from fastapi import APIRouter, Request
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
                    {'_id': 432274227563069451, 'name': 'John Smith', 'age': 20},
                    {'_id': 562627439967832726, 'type': 'student', 'modules': ['P1456235', 'P1655578']},
                    {'_id': 465612315423184238, 'name': 'Foo Bar', 'vip': True},
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
    resp = milvus.users.insert([[f.embedding for f in req.faces]])

    mongodb.users.insert_many([
        {'_id': pk, **f.data}
        for f, pk
        in zip(req.faces, resp.primary_keys)
    ])

    for face, key in zip(faces, resp.primary_keys):
        s3.put_object(
            ACL='public-read',
            Bucket='users',
            Key=f'{key}.jpg',
            Body=cv2.imencode('.jpg', cv2.cvtColor(face, cv2.COLOR_RGB2BGR))[1].tostring(),
        )

    return None
