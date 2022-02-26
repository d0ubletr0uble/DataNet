from fastapi import APIRouter

router = APIRouter()


@router.get('/')
def root():
    return {'hello': 'world'}


@router.get('/hello')
def hello():
    return "hello #333"

