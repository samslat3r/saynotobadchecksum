import os
import json
import time
import boto3

s3 = boto3.client('s3')
secrets = boto3.client('secretsmanager')

BUCKET = os.environ['UPLOADS_BUCKET']
USE_API_KEY = os.environ.get('USE_API_KEY', 'false').lower() == 'true' 
SECRET_ID = os.environ.get('PRESIGN_SECRET_ID')
# Whatever just choose some file types for an example 
ALLOWED_CONTENT_TYPES = [ 
                         "application/pdf", "image/png", "image/jpeg",
                            "application/zip", "application/x-zip-compressed",
                            "text/plain", "text/csv", "application/msword",
                            "application/octet-stream",
                        ]

_api_key_cache = None

def _get_api_key(): 
    global _api_key_cache
    if _api_key_cache:
        return _api_key_cache
    if not SECRET_ID:
        return None
    v = secrets.get_secret_value(SecretID=SECRET_ID)
    _api_key_cache = json.loads(v['SecretString'])['PRESIGN_API_KEY']
    return _api_key_cache

def _unauth(body="unauthorized"):
    return { 'statusCode': 401, 'body': body }

def handler(event, context):
    headers = { (k or '').lower(): v for k, v in (event.get('headers') or {}).items() }
    if USE_API_KEY:
        provided = headers.get('x-api-key')
        if not provided or provided != _get_api_key():
            return _unauth()
        
    body = json.loads(event.get('body') or '{}' ) 
    content_type = body.get('content_type')
    key_prefix = body.get('prefix', 'user-uploads/')
    filename = body.get('filename', f'upload-{int(time.time())}')
    
    # Validate content type
    
    if not content_type or content_type not in ALLOWED_CONTENT_TYPES:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid or missing content_type'})
        }
    
    key = f"{key_prefix}/{int(time.time())}-{filename}"
    
    # "PUT" presigns can't enforce max size, only "POST" can
    
    url = s3.generate_presigned_url(
        ClientMethod='put_object',
        Params={ 'Bucket': BUCKET, 'Key': key, 'ContentType': content_type },
        ExpiresIn=300
    )
    print("Generated presigned URL:", url)
    return {
        'statusCode': 200,
        'body': json.dumps({'url': url, 'key': key})
    }
    

# It wasn't ContextType but content_type and filename not file_name 