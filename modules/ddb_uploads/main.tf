resource "aws_dynamodb_table" "main" { 
    name = var.table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"

    attribute {
        name = "object_key"
        type = "S"
    }
    tags = var.tags
}
