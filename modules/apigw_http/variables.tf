variable "name" {
  description = "API name"
  type        = string
}
variable "routes" {
    description = "List of route objects"
    type = list(object({
        method    = string
        path      = string
        lambda_arn = string
        lambda_name = string
    }))
}