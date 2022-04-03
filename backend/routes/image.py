import base64
from typing import List

import cv2
from fastapi import APIRouter, Form
from pydantic import BaseModel
from backend.utils import utils

from backend.ai_models import detector

model = detector.instance
router = APIRouter()


class FaceSummary(BaseModel):
    face: str
    embedding: List[float]


class UploadSummary(BaseModel):
    faces: List[FaceSummary] = []


@router.post('/upload', response_model=UploadSummary)
def upload(image: str = Form(...)):
    img = utils.base64_to_cv2(image)
    detected_faces, prepared_faces = model.get_faces(img)

    embeddings = model.get_embeddings(prepared_faces)

    result = UploadSummary()
    if not len(detected_faces) > 0:
        return result

    result.faces = [
        FaceSummary(
            face=base64.b64encode(cv2.imencode('.jpg', cv2.cvtColor(face, cv2.COLOR_RGB2BGR))[1].tostring()),
            embedding=emb.tolist(),
        )
        for face, emb in zip(detected_faces, embeddings)
    ]

    return result
