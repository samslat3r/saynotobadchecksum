resource "aws_lambda_function" "main" {
    function_name = var.name
    role = var.role_arn
    handler = var.handler
    runtime = var.runtime
    filename = var.filename
    source_code_hash = filebase64sha256(var.filename)
    timeout = var.timeout
    memory_size = var.memory_size
    environment { variables = var.env }
}