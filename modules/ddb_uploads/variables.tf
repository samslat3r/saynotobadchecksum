variable "table_name" { description = "DynamoDB table name" type = string }
variable "tags" { description = "Common tags" type = map(string) default = {} }