import json
import boto3
from lambdas.process_upload.handler import handler as process_handler
from importlib import reload

# Fake VT lookup - don't need to hit the network
def fake_vt_lookup(hash_hex, vt_key):
    is_malicious = hash_hex.endswith("bad")
    result = "malicious" if is_malicious else "clean"
    return {
        "malicious": 1 if is_malicious else 0,
        "suspicious": 0,
        "undetected": 70,
        "result": result
    }
    
def test_process_marks_and_deletes_malicious(monkeypatch):
    s3 = boto3.client("s3")
    ddb = boto3.resource("dynamodb")
    sm = boto3.client("secretsmanager")
    
    s3.create_bucket(Bucket="uploads-dev", CreateBucketConfiguration={'LocationConstraint': 'us-west-2'})
    ddb.create_table(
        TableName="uploads-dev",
        KeySchema=[{"AttributeName":"object_key", "KeyType":"HASH"}],
        BillingMode="PAY_PER_REQUEST",
        AttributeDefinitions=[{"AttributeName":"object_key", "AttributeType":"S"}]
    )
    sid = sm.create_secret(Name="dev-virustotal")["ARN"]
    sm.put_secret_value(SecretId=sid, SecretString=json.dumps({"VT_API_KEY":"vt_test"}))
    
    s3.put_object(Bucket="uploads-dev", Key="sam/evil.exe", Body=b"badbadbad666")

    monkeypatch.setenv("DDB_TABLE", "uploads-dev")
    monkeypatch.setenv("VT_SECRET_ID", sid)
    
    # Patch functions in the module under test
    from lambdas.process_upload import handler as mod 
    reload(mod)
    from lambdas.process_upload.handler import handler as process_handler
    
    monkeypatch.setattr(mod, "_vt_lookup", fake_vt_lookup)
    monkeypatch.setattr(mod, "_sha256_stream", lambda b,k: ("evilbad", 3))
    
    event = { "Records" : [
        {
            "s3": {
                "bucket": { "name" : "uploads-dev" },
                "object": { "key" : "sam/evil.exe" }
            }
        }
    ]}
    process_handler(event, None)
    
    # Check to make sure the file was deleted
    listed = s3.list_objects_v2(Bucket="uploads-dev", Prefix="sam/")
    assert listed.get("KeyCount", 0) == 0
    
    # Make sure DynamoDB was updated
    table = ddb.Table("uploads-dev")
    items = table.scan().get("Items", [])
    assert items and items[0]["status"] == "deleted_malicious"
    