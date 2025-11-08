variable "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  type        = string
}

variable "bucket_id" {
  description = "The ID/name of the S3 bucket"
  type        = string
}

variable "origin_access_identity_path" {
  description = "Path to CloudFront origin access identity (optional, for OAI-based access)"
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Alternative domain names (CNAMEs) for the distribution"
  type        = list(string)
  default     = []
}

variable "price_class" {
  description = "Price class for CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags to apply to the CloudFront distribution"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}
