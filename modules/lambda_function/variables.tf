variable "name" {
  description = "Lambda function name"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN"
  type        = string
}

# Prebuilt zip 
variable "filename" {
  description = "Path to zip artifact"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime env like python3.12"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Handler"
  type        = string
  default     = "handler.handler"
}

variable "timeout" {
  description = "Timeout (seconds)"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Memory (MB)"
  type        = number
  default     = 256
}

variable "env" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

# Prefer over filename
variable "source_dir" {
  type    = string
  default = ""
}



variable "excludes" {
  type    = list(string)
  default = ["tests", "__pycache__", "*.pyc", ".pytest_cache"]
}