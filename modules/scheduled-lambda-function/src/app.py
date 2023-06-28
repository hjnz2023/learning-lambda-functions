import boto3
import requests
import json
import os
from requests_aws4auth import AWS4Auth

def lambda_handler(event, context):
    host = os.environ.get("HOST")
    snapshot_repository = os.environ.get("SNAPSHOT_REPOSITORY")
    region = 'ap-southeast-2' # e.g. us-west-1
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    # Register repository

    path = f'_snapshot/{snapshot_repository}/_all' # the OpenSearch API endpoint

    headers = {"Content-Type": "application/json"}

    r = requests.get(f'{host}{path}', auth=awsauth, headers=headers)

    print(r.text)
    # print(json.dumps(event))