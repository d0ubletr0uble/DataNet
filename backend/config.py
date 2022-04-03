import os

MILVUS_HOST = 'datanet-milvus'
BUCKET_URL = 'http://datanet-minio:9000'
MONGO_URL = 'mongodb://datanet-mongodb:27017/'

if os.getenv('ENV') == 'local':
    MILVUS_HOST = '127.0.0.1'
    BUCKET_URL = 'http://127.0.0.1:9000'
    MONGO_URL = 'mongodb://127.0.0.1:27017/'
