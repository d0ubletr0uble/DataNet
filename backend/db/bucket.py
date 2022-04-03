import json

import boto3
from botocore.client import ClientError
from backend.config import *


class Bucket:
    def __init__(self):
        self.client = boto3.client(
            service_name='s3',
            aws_access_key_id='minioadmin',
            aws_secret_access_key='minioadmin',
            endpoint_url=BUCKET_URL,
        )

        policy = {
            'Version': '2012-10-17',
            'Statement': [{
                'Effect': 'Allow',
                'Principal': {'AWS': ['*']},
                'Action': ['s3:GetObject'],
                'Resource': 'arn:aws:s3:::users/*'
            }]
        }

        try:
            self.client.create_bucket(Bucket='users')
            self.client.put_bucket_policy(Bucket='users', Policy=json.dumps(policy))
        except ClientError as err:
            print(err)


instance = Bucket()
