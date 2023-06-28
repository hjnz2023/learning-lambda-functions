import boto3
import requests
import json
import os
from requests_aws4auth import AWS4Auth

def lambda_handler(event, context):
    host = os.environ.get("MESSAGE")
    region = 'ap-southeast-2' # e.g. us-west-1
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    # Register repository

    path = '_snapshot/_all' # the OpenSearch API endpoint
    url = host + path

    headers = {"Content-Type": "application/json"}

    r = requests.get(url, auth=awsauth, headers=headers)

    print(r.status_code)
    print(r.text)
    print(json.dumps(event))