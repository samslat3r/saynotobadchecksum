output "api_base_url" {
    description = "HTTP API base URL"
    value = module.api.api_endpoint
}

output "bucket_name" {
    description = "Uploads bucket name"
    value = module.s3.bucket_name
}

output "ddb_table" {
    description = "DynamoDB table name"
    value = module.ddb.table_name
}

# CI secret injection (post-apply)

output "vt_secret_arn" {
    value = module.secrets.vt_secret_arn
}


output "presign_secret_arn" {
    value = module.secrets.presign_secret_arn
}