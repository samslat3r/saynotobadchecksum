variable "name_prefix" {
  type = string
}

variable "owner" {
  type = string
}

variable "repo" {
  type = string
}

variable "branch" {
  type = string
}

# Optional inline policy JSON to override the default

variable "policy_json" {
  description = "Optional inline policy JSON to override the default"
  type        = string
  default     = ""

}

