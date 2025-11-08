variable "bucket_name" {
  description = "Name of the S3 bucket for static site hosting"
  type        = string
}

variable "cloudfront_arn" {
  description = "ARN of the CloudFront distribution (for bucket policy)"
  type        = string
  default     = ""
}

variable "cors_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
