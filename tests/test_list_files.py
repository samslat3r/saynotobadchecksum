import json
import boto3
from lambdas.list_files.handler import handler as list_handler

def test_list_returns_sorted_items(monkeypatch):
    ddb = boto3.client("dynamodb")
    table = ddb.create_table(
        TableName="uploads-dev",
        KeySchema=[{"AttributeName":"object_key", "KeyType":"HASH"}],
        AttributeDefinitions=[{"AttributeName":"object_key", "AttributeType":"S"}],
        BillingMode="PAY_PER_REQUEST",
    )
    ddb.put_item(
        TableName="uploads-dev",
        Item={
            "object_key":{"S":"b"},
            "uploaded_at": {"S": "2025-10-10T10:10:10Z"}
        }
    )
    ddb.put_item(
        TableName="uploads-dev",
        Item={
            "object_key":{"S":"a"},
            "uploaded_at": {"S": "2025-10-09T10:10:10Z"}
        }
    )
    monkeypatch.setenv("DDB_TABLE","uploads-dev")
    
    resp = list_handler({}, {}) 
    assert resp["statusCode"] == 200
    items = json.loads(resp["body"])
    assert [i["object_key"] for i in items] == ["b","a"]
    
    