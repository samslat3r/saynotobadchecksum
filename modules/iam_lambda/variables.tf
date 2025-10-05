variable "name_prefix" { description = "Name Prefix" type = string }
variable "s3_bucket_arn" { description = "Uploads bucket ARN" type = string }
variable "ddb_table_arn" { description = "Uploads table ARN" type = string }
variable "secret_arns" { description = "Secrets ARNs for lambdas" type = list(string) }