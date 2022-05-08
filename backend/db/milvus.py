from backend.config import *

from milvus import Milvus, MetricType


class Milvuss:
    def __init__(self):
        milvus = Milvus(MILVUS_HOST, '19530')

        _, ok = milvus.has_collection('users')
        if not ok:
            milvus.create_collection({
                'collection_name': 'users',
                'dimension': 128,
                'metric_type': MetricType.L2
            })

        self.milvus = milvus


instance = Milvuss()
