from fastapi import FastAPI
import uvicorn
from routes import image
import ai_models.detector as facenet
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(image.router, prefix='/image', tags=['image'])

detector = facenet.instance

if __name__ == '__main__':
    uvicorn.run('main:app', host='0.0.0.0', port=8080)
