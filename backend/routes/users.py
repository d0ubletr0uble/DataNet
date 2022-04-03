import http
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


@router.post('', status_code=http.HTTPStatus.CREATED)
async def upload(req: FaceList):
    if len(req.faces) == 0:
        return None

    faces = [utils.base64_to_cv2(f.face) for f in req.faces]
    # embeddings = model.get_embeddings(model.prepare_faces(faces)).tolist()

    # data persistence
    resp = milvus.users.insert([[f.embedding for f in req.faces]])

    mongodb.users.insert_many([
        {'_id': pk, 'data': f.data}
        for f, pk
        in zip(req.faces, resp.primary_keys)
    ])

    for face, key in zip(faces, resp.primary_keys):
        s3.put_object(
            Bucket='users',
            Key=f'{key}.jpg',
            Body=cv2.imencode('.jpg', cv2.cvtColor(face, cv2.COLOR_RGB2BGR))[1].tostring(),
        )

    return None
