output "api_base_url" {
  description = "HTTP API base URL"
  value       = module.api.api_endpoint
}

output "bucket_name" {
  description = "Uploads bucket name"
  value       = module.s3.bucket_name
}

output "ddb_table" {
  description = "DynamoDB table name"
  value       = module.ddb.table_name
}

# CI secret injection (post-apply)

output "vt_secret_arn" {
  value = module.secrets.vt_secret_arn
}


output "presign_secret_arn" {
  value = module.secrets.presign_secret_arn
}

output "role_arn" {
  value       = module.gha_oidc.role_arn
  description = "IAM Role ARN for GitHub Actions OIDC"
}

output "web_bucket_name" {
  description = "Name of the S3 bucket for web assets"
  value       = module.web_s3.bucket_id
}

output "website_url" {
  description = "CloudFront URL for the website"
  value       = module.cloudfront.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

# Lambda function names for post-deployment validation
output "lambda_presign_name" {
  description = "Presign Lambda function name"
  value       = module.lambda_presign.name
}

output "lambda_list_files_name" {
  description = "List files Lambda function name"
  value       = module.lambda_list.name
}

output "lambda_process_upload_name" {
  description = "Process upload Lambda function name"
  value       = module.lambda_process.name
}