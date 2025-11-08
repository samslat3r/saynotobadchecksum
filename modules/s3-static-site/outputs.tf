output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.web.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.web.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket"
  value       = aws_s3_bucket.web.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The website endpoint"
  value       = aws_s3_bucket_website_configuration.web.website_endpoint
}
