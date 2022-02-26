from fastapi import FastAPI
import uvicorn
from routes import test

app = FastAPI()
app.include_router(test.router, prefix='/test', tags=['test'])

if __name__ == '__main__':
    uvicorn.run('main:app', host='0.0.0.0', port=8000)
