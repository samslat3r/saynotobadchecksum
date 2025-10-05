variable "bucket_id" { description = "Bucket ID" type = string }
variable "bucket_arn" { description = "Bucket ARN" type = string }
variable "lambda_arn" { description = "Lambda ARN" type = string }
variable "lambda_name" { description = "Lambda Name" type = string }
variable "events" { description = "event types" type = list(string) }