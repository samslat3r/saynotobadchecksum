variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}
variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}