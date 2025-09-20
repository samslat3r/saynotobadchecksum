variable project_name {type = string default = "sam-secure" }
variable "env"  {type = string default = "dev" }
variable "aws_region" {type = string default = "us-west-2" }

variable "bucket_name" {type string default = "" }
variable "ddb_table_name" {type = string default = "" }

variable "vt_api_key" { type = string sensitive = true }
variable "presign_api_key" {type = string sensitive = true }

# Lambda packaging: point to artifacts built by Jenkins into lambdas/dist-*.zip

variable "lambda_artifacts" {
    type = object({
        presign = string
        list_files = string
        process_upload = string
    })
    default = { 
        presign = "../lambdas/dist-presign.zip"
        list_files = "../lambdas/dist-list-files.zip"
        process_upload = "../lambdas/dist-process_upload.zip"
    }
}