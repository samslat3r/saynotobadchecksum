import os
import json
import boto3

ddb = boto3.resource('dynamodb')

table = ddb.Table(os.environ['DDB_TABLE'])

# Scan for demo. For scaling, we could use DDB's GSI to index by user or date or
# we could use pagination tokens to fetch in chunks

def handler(event, context):
    resp = table.scan(Limit=200)
    items = resp.get('Items', [])
    items.sort(key=lambda x: x.get('uploaded_at', ''), reverse=True)
    return {
        'statusCode': 200,
        'headers': { 'content-type': 'application/json' },
        'body': json.dumps(items)
    }