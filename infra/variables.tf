variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "sam-secure"
}
variable "env" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "Override S3 Bucket Name (optional)"
  type        = string
  default     = ""
}
variable "ddb_table_name" {
  description = "Override DynamoDB Table Name (optional)"
  type        = string
  default     = ""
}

variable "vt_api_key" {
  description = "VirusTotal API Key"
  type        = string
  sensitive   = true
}
variable "presign_api_key" {
  description = "API key used by /presign"
  type        = string
  sensitive   = true
}


variable "lambda_artifacts" {
    description = "Paths to Lambda deployment packages"
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

# GitHub OIDC variables

variable "github_owner" {
  type        = string
  default = "samslat3r"
}

variable "github_repo" {
  type        = string
  default = "saynotobadchecksum"
}
variable "github_branch" {
  type        = string
  default = "master"
}