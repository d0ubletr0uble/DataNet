import base64
from typing import List

import cv2
import numpy as np
from fastapi import APIRouter, Form
from pydantic import BaseModel

from backend.ai_models import detector

model = detector.instance
router = APIRouter()


class UploadSummary(BaseModel):
    embeddings: List[List[float]] = []
    faces: List[bytes] = []


@router.post('/upload', response_model=UploadSummary)
def upload(image: str = Form(...)):
    buffer = np.frombuffer(base64.b64decode(image), dtype=np.uint8)
    img = cv2.imdecode(buffer, flags=1)

    faces = model.get_faces(img)
    result = UploadSummary()
    if len(faces) > 0:
        result.embeddings = model.get_embeddings(model.prepare_faces(faces)).tolist()
        result.faces = [base64.b64encode(cv2.imencode('.jpg', face)[1].tostring()) for face in faces]

    return result
