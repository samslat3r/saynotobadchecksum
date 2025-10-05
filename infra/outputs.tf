output "api_base_url" { description = "HTTP API base URL" value = module.api.api_endpoint }
output "bucket_name" { description = "Uploads S3 Bucket Name" value = module.s3.bucket_name }
output "ddb_table" { description = "DynamoDB table name" value = module.ddb.table_name }
