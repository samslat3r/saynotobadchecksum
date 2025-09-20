resource "aws_dynamodb_table" "uploads" {
    name    = local.ddb_table_name
    billing_mode    = "PAY_PER_REQUEST"
    hash_key        = "object_key"

    attribute {name = "object_key" type = "S" }
    
    tags = {Project = local.project, Env = local.env}
}