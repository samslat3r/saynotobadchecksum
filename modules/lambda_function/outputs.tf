output "lambda_arn" { description = "Lambda ARN" value = aws_lambda_function.main.arn }
output "name" { description = "Lambda Name" value = aws_lambda_function.main.function_name }