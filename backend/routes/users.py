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

    class Config:
        schema_extra = {
            'example': {
                'faces': [
                    {
                        'face': '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',
                        'embedding': [
                            0.5660603046417236,
                            2.322317600250244,
                            -0.6594178080558777,
                            0.05136125534772873,
                            0.7643716931343079,
                            0.5217048525810242,
                            0.13821002840995789,
                            0.6377778053283691,
                            0.9042218327522278,
                            -0.7449147701263428,
                            1.8083280324935913,
                            -0.5437456965446472,
                            -0.5868111252784729,
                            0.10837182402610779,
                            -0.6136823892593384,
                            0.12784983217716217,
                            -2.025036573410034,
                            -2.3382158279418945,
                            -1.8519713878631592,
                            0.781427800655365,
                            -0.33932751417160034,
                            1.6574609279632568,
                            0.061191774904727936,
                            -0.6277986168861389,
                            1.5323078632354736,
                            -0.18873602151870728,
                            -0.18633827567100525,
                            -1.0978296995162964,
                            0.1718374788761139,
                            -0.8572045564651489,
                            -0.5258802175521851,
                            -1.3012206554412842,
                            -0.8057977557182312,
                            0.0687166228890419,
                            -1.1533335447311401,
                            0.2920658588409424,
                            0.058601487427949905,
                            0.8712714314460754,
                            0.9922592639923096,
                            -0.43199285864830017,
                            -0.07929405570030212,
                            -0.07269831746816635,
                            -1.8162546157836914,
                            0.3174280822277069,
                            -0.4595174789428711,
                            -0.26936566829681396,
                            -0.5877677798271179,
                            0.6801387071609497,
                            0.5307405591011047,
                            0.06090279296040535,
                            0.12714791297912598,
                            2.4119975566864014,
                            0.2903570830821991,
                            -0.9804561734199524,
                            -0.2862361967563629,
                            -1.2950396537780762,
                            0.7596532106399536,
                            -0.9979323744773865,
                            0.21631014347076416,
                            0.8690982460975647,
                            1.0227301120758057,
                            0.03317924588918686,
                            -0.8714162707328796,
                            -1.3002647161483765,
                            0.7901629209518433,
                            -0.6267474889755249,
                            -1.493292212486267,
                            0.46170422434806824,
                            -2.1376142501831055,
                            -1.0555005073547363,
                            -1.3634663820266724,
                            -0.6483104228973389,
                            -2.314760208129883,
                            -1.793688416481018,
                            1.3303146362304688,
                            0.811326265335083,
                            -0.2311602532863617,
                            2.554844617843628,
                            0.08770222216844559,
                            0.39649534225463867,
                            -0.16732490062713623,
                            0.2396545112133026,
                            -0.11351844668388367,
                            0.29185035824775696,
                            -0.17194274067878723,
                            1.5448112487792969,
                            -1.6378326416015625,
                            0.6579031348228455,
                            0.0345311313867569,
                            -2.559993267059326,
                            1.7621450424194336,
                            -0.12773627042770386,
                            2.5411758422851562,
                            -1.0523498058319092,
                            1.706666111946106,
                            1.0107920169830322,
                            -0.49762484431266785,
                            -0.5999301671981812,
                            -0.34216463565826416,
                            -0.9197160005569458,
                            0.09782926738262177,
                            -0.8771651983261108,
                            -1.6294361352920532,
                            -0.4478013813495636,
                            -0.7974284887313843,
                            0.06968171894550323,
                            0.655831515789032,
                            0.47491106390953064,
                            -0.4205208420753479,
                            0.9802945256233215,
                            -0.73448246717453,
                            -0.7143816351890564,
                            1.1619857549667358,
                            -1.4652619361877441,
                            0.21152763068675995,
                            1.084835171699524,
                            -2.0002169609069824,
                            0.13808922469615936,
                            0.07653718441724777,
                            1.6314316987991333,
                            -0.40723782777786255,
                            -0.43096694350242615,
                            -0.2122117131948471,
                            -0.43746426701545715,
                            1.434300184249878,
                            -1.3535056114196777,
                            -0.5979769229888916,
                            1.0257285833358765
                        ],
                        'data': {
                            'name': 'John Smith',
                            'age': 20
                        }
                    }
                ]
            }
        }


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


class BatchEditResponse(BaseModel):
    updated: int

    class Config:
        schema_extra = {
            'example': {
                'updated': 3
            }
        }


@router.post('/search', status_code=http.HTTPStatus.OK, response_model=UsersResponse, description='takes any json as '
                                                                                                  'request body')
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


@router.put('/{user_id}', status_code=http.HTTPStatus.OK, description='takes any json as request body')
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

    class Config:
        schema_extra = {
            'example': {
                'embedding': [
                    0.5660603046417236,
                    2.322317600250244,
                    -0.6594178080558777,
                    0.05136125534772873,
                    0.7643716931343079,
                    0.5217048525810242,
                    0.13821002840995789,
                    0.6377778053283691,
                    0.9042218327522278,
                    -0.7449147701263428,
                    1.8083280324935913,
                    -0.5437456965446472,
                    -0.5868111252784729,
                    0.10837182402610779,
                    -0.6136823892593384,
                    0.12784983217716217,
                    -2.025036573410034,
                    -2.3382158279418945,
                    -1.8519713878631592,
                    0.781427800655365,
                    -0.33932751417160034,
                    1.6574609279632568,
                    0.061191774904727936,
                    -0.6277986168861389,
                    1.5323078632354736,
                    -0.18873602151870728,
                    -0.18633827567100525,
                    -1.0978296995162964,
                    0.1718374788761139,
                    -0.8572045564651489,
                    -0.5258802175521851,
                    -1.3012206554412842,
                    -0.8057977557182312,
                    0.0687166228890419,
                    -1.1533335447311401,
                    0.2920658588409424,
                    0.058601487427949905,
                    0.8712714314460754,
                    0.9922592639923096,
                    -0.43199285864830017,
                    -0.07929405570030212,
                    -0.07269831746816635,
                    -1.8162546157836914,
                    0.3174280822277069,
                    -0.4595174789428711,
                    -0.26936566829681396,
                    -0.5877677798271179,
                    0.6801387071609497,
                    0.5307405591011047,
                    0.06090279296040535,
                    0.12714791297912598,
                    2.4119975566864014,
                    0.2903570830821991,
                    -0.9804561734199524,
                    -0.2862361967563629,
                    -1.2950396537780762,
                    0.7596532106399536,
                    -0.9979323744773865,
                    0.21631014347076416,
                    0.8690982460975647,
                    1.0227301120758057,
                    0.03317924588918686,
                    -0.8714162707328796,
                    -1.3002647161483765,
                    0.7901629209518433,
                    -0.6267474889755249,
                    -1.493292212486267,
                    0.46170422434806824,
                    -2.1376142501831055,
                    -1.0555005073547363,
                    -1.3634663820266724,
                    -0.6483104228973389,
                    -2.314760208129883,
                    -1.793688416481018,
                    1.3303146362304688,
                    0.811326265335083,
                    -0.2311602532863617,
                    2.554844617843628,
                    0.08770222216844559,
                    0.39649534225463867,
                    -0.16732490062713623,
                    0.2396545112133026,
                    -0.11351844668388367,
                    0.29185035824775696,
                    -0.17194274067878723,
                    1.5448112487792969,
                    -1.6378326416015625,
                    0.6579031348228455,
                    0.0345311313867569,
                    -2.559993267059326,
                    1.7621450424194336,
                    -0.12773627042770386,
                    2.5411758422851562,
                    -1.0523498058319092,
                    1.706666111946106,
                    1.0107920169830322,
                    -0.49762484431266785,
                    -0.5999301671981812,
                    -0.34216463565826416,
                    -0.9197160005569458,
                    0.09782926738262177,
                    -0.8771651983261108,
                    -1.6294361352920532,
                    -0.4478013813495636,
                    -0.7974284887313843,
                    0.06968171894550323,
                    0.655831515789032,
                    0.47491106390953064,
                    -0.4205208420753479,
                    0.9802945256233215,
                    -0.73448246717453,
                    -0.7143816351890564,
                    1.1619857549667358,
                    -1.4652619361877441,
                    0.21152763068675995,
                    1.084835171699524,
                    -2.0002169609069824,
                    0.13808922469615936,
                    0.07653718441724777,
                    1.6314316987991333,
                    -0.40723782777786255,
                    -0.43096694350242615,
                    -0.2122117131948471,
                    -0.43746426701545715,
                    1.434300184249878,
                    -1.3535056114196777,
                    -0.5979769229888916,
                    1.0257285833358765
                ]
            }
        }


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


@router.post('/batch-edit', response_model=BatchEditResponse)
def upload(image: str = Form(..., description='base64 encoded image bytes'),
           data: str = Form(..., description='json data')):
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
