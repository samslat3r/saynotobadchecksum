import os
import json
import hashlib
import urllib.request
import urllib.parse
from datetime import datetime, timezone

import boto3

s3 = boto3.client('s3')
ddb = boto3.resource('dynamodb')
secrets = boto3.client('secretsmanager')

table = ddb.Table(os.environ['DDB_TABLE'])
vt_secret_id = os.environ['VT_SECRET_ID']
VT_BASE = 'https://www.virustotal.com/api/v3/files/'

_vt_key_cache = None

def _get_vt_key():
    global _vt_key_cache
    if _vt_key_cache:
        return _vt_key_cache
    resp = secrets.get_secret_value(SecretId=vt_secret_id)
    _vt_key_cache = json.loads(resp['SecretString'])['VT_API_KEY']
    return _vt_key_cache

def _sha256_stream(bucket, key): 
    hasher = hashlib.sha256()
    obj = s3.get_object(Bucket=bucket, Key=key)
    body = obj['Body']
    for chunk in  body.iter_chunks(chunk_size=8 * 1024 * 1024):
        if chunk: 
            hasher.update(chunk)
    return hasher.hexdigest(), obj['ContentType']

def _vt_lookup(hash_hex, vt_key):
    req = urllib.request.Request(
        VT_BASE + hash_hex,
        headers={'x-apikey': vt_key}
    )
    try:
       with urllib.request.urlopen(req, timeout=10) as r:
           data = json.loads(r.read())
           stats = data['data']['attributes']['last_analysis_stats']
           result = 'malicious' if stats.get('malicious', 0) > 0  else (
               'suspicious' if stats.get('suspicious', 0) > 0 else 'clean'
           )
           return {
               'malicious': stats.get('malicious', 0), 
               'suspicious': stats.get('suspicious', 0),
               'undetected': stats.get('undetected', 0),
               'result': result,
           }
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return {'malicious': 0, 'suspicious': 0, 'undetected': 0, 'result': 'unknown'}
        raise

def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        uploaded_at = record.get('eventTime', datetime.now(timezone.utc).isoformat()) + 'Z'
        now = datetime.now(timezone.utc).isoformat() + 'Z'
        try:
            sha256, size = _sha256_stream(bucket, key)
            vt_key = _get_vt_key()
            vt = _vt_lookup(sha256, vt_key)
            
            status = vt['result']
            if status in ('malicious', 'suspicious'):
                #delete object from s3 bucket
                s3.delete_object(Bucket=bucket, Key=key)
                status = 'deleted_malicious'
            
            # Always write to DynamoDB regardless of status
            table.put_item(Item={
                'id': key,
                'object_key': key,
                'bucket': bucket,
                'size': size,
                'sha256': sha256,
                'status': status,
                'vt_malicious': vt['malicious'],
                'vt_suspicious': vt['suspicious'],
                'vt_undetected': vt['undetected'],
                'uploaded_at': uploaded_at,
                'scanned_at': now,
                'uploader': record.get('userIdentity', {}).get('principalId', 'unknown')
            })
        except Exception as e:
            table.put_item(Item={
                'id': key,
                'object_key': key,
                'bucket': bucket,
                'size': record['s3']['object'].get('size', 0),
                'sha256': 'n/a',
                'status': 'error',
                'error': str(e),
                'uploaded_at': uploaded_at,
            })
            raise
            
        

        
           
           
    