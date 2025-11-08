import os
import json
import boto3
from decimal import Decimal

ddb = boto3.resource('dynamodb')

table = ddb.Table(os.environ['DDB_TABLE'])

# Scan for demo. For scaling, we could use DDB's GSI to index by user or date or
# we could use pagination tokens to fetch in chunks

def _json_default(o):
    if isinstance(o, Decimal):
        # Convert Decimals from DynamoDB to int/float for JSON serialization
        return int(o) if o % 1 == 0 else float(o)
    raise TypeError(f"Object of type {type(o).__name__} is not JSON serializable")

def handler(event, context):
    resp = table.scan(Limit=200)
    items = resp.get('Items', [])
    items.sort(key=lambda x: x.get('uploaded_at', ''), reverse=True)
    return {
        'statusCode': 200,
        'headers': { 
            'content-type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Api-Key',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        },
        'body': json.dumps(items, default=_json_default)
    }