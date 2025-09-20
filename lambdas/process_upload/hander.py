import os
import json
import hashlib
import urllib.request
import urllib.parse
from datetime import datetime

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
    resp = secrets.get_secret_value(SecretID=vt_secret_id)
    _vt_key_cache = json.loads(resp['SecretString'])['VT_API_KEY']