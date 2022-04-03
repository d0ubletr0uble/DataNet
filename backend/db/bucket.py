import boto3
from botocore.client import ClientError


class Bucket:
    def __init__(self):
        self.client = boto3.client(
            service_name='s3',
            aws_access_key_id='minioadmin',
            aws_secret_access_key='minioadmin',
            endpoint_url='http://datanet-minio:9000',
            # endpoint_url='http://127.0.0.1:9000',
        )

        try:
            self.client.create_bucket(Bucket='users')
        except ClientError:
            pass


instance = Bucket()
