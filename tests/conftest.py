import json
import os
import boto3
import pytest
from moto import mock_aws

os.environ.setdefault('DDB_TABLE', 'uploads-dev')
os.environ.setdefault('UPLOADS_BUCKET', 'test-bucket')
os.environ.setdefault('AWS_DEFAULT_REGION', 'us-west-2')
os.environ.setdefault('VT_SECRET_ID', 'dev-virustotal')
os.environ.setdefault('AWS_ACCESS_KEY_ID', 'test')
os.environ.setdefault('AWS_SECRET_ACCESS_KEY', 'test')


@pytest.fixture(autouse=True)
def _env(monkeypatch):
    monkeypatch.setenv("AWS_DEFAULT_REGION", "us-west-2")
    # Dummy AWS creds so boto will not use real ones
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", os.getenv("AWS_ACCESS_KEY_ID", "test"))
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", os.getenv("AWS_SECRET_ACCESS_KEY", "test"))
    
@pytest.fixture(autouse=True, scope="function")
def moto_ctx():
    with mock_aws():
        yield


@pytest.fixture
def secrets_setup():
    sm = boto3.client("secretsmanager")
    vt =sm.create_secret(Name="dev-virustotal")["ARN"]
    pres = sm.create_secret(Name="dev-presigned")["ARN"]
    sm.put_secret_value(SecretId=vt, SecretString=json.dumps({"VT_API_KEY:": "vt_test"}))
    sm.put_secret_value(SecretId=pres, SecretString=json.dumps({"PRESIGNED_API_KEY": "supersecret"}))
    return {"vt_arn": vt, "pres_arn": pres}