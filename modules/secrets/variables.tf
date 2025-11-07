variable "name_prefix" {
  description = "Name prefix"
  type        = string
}

variable "kms_key_id" {
  description = "Optional KMS key ARN/ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "recovery_window_in_days" {
  description = "SecretsManager recovery window (7-30)"
  type        = number
  default     = 7
}