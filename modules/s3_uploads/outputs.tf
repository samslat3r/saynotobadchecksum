output "bucket_name" {
  description = "Name of S3 Bucket"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_id" {
  description = "ID of S3 Bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of S3 Bucket"
  value       = aws_s3_bucket.main.arn
}
