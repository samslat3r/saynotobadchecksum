import json
import boto3
from lambdas.presign.handler import handler as presign_handler

def test_presign_auth_and_url(secrets_setup, monkeypatch):
    s3 = boto3.client("s3")
    s3.create_bucket(Bucket="uploads-dev", CreateBucketConfiguration={'LocationConstraint': 'us-west-2'})
    monkeypatch.setenv("UPLOADS_BUCKET", "uploads-dev")
    monkeypatch.setenv("USE_API_KEY", "true")
    monkeypatch.setenv("PRESIGN_SECRET_ID", secrets_setup["pres_arn"])
    
    event = {
        "headers" : {"x-api-key": "supersecret"},
        "body": json.dumps({"filename": "a.txt", "content_type": "text/plain", "prefix": "sam"})
    }
    resp = presign_handler(event, None) 
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert "url" in body and "key" in body
    assert body["key"].startswith("sam/")
    
def test_presign_rejects_bad_content_type(monkeypatch):
    monkeypatch.setenv("UPLOADS_BUCKET", "any")
    monkeypatch.setenv("USE_API_KEY", "false")
    event = {
        "headers" : {},
        "body": json.dumps({"filename": "jurassic_park_3_full.mp4", "content_type": "bad/x-evil", "prefix": "sam"})
    }
    resp = presign_handler(event, None)
    assert resp["statusCode"] == 400
    