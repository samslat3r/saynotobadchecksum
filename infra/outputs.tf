output "api_base_url" {
    value = aws_apigatewayv2_api.api.api_endpoint
}

output "bucket_name" {
    value = aws_s3_bucket.uploads.bucket
}

output "ddb_table" { value = aws_dynamodb_table.uploads.name }