resource "aws_apigatewayv2_api" "api" {
name = "${local.project}-${local.env}-api"
protocol_type = "HTTP"
}

# Presign part 

resource "aws_lambda_function" "presign" {
    function_name = "${local.lambda_prefix}-presign"
    role = aws_iam_role.lambda_role.arn
    handler = "handler.handler"
    runtime = "python3.12"
    filename = var.lambda_artifacts.presign
    source_code_hash = filebase64sha256(var.lambda_artifacts.presign)
    timeout     = 10
    environment {
        variables = {
            UPLOADS_BUCKET = aws_s3_bucket.uploads.bucket
            USE_API_KEY     = "true"
            PRESIGN_SECRET_ID= aws_secretsmanager_secret.presign.id
            }
        }

resource "aws_apigatewayv2_api_integration" "presign" {
    api_id = aws_apigatewayv2_api.api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.presign.invoke_arn
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "presign" {
    api_id  = aws_apigatewayv2_api.api.id
    route_key = "POST /presign"
    target = "integrations/${aws_apigatewayv2_integration.presign.id}"
}
resource "aws_lambda_permission" "apigw_presign_invoke" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.presign.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}


# List files


resource "aws_lambda_function" "list_files {
    function_name = "${local.lambra_prefix}-list-files"
    role = aws_iam_role.lambda_role.arn
    handler = "handler.handler"
    runtime = "python3.12"
    filename = var.lambda_artifacts.list_files
    source_code_hash = filebase64sha256(var.lambda_artifacts.list_files)
    timeout = 10
    environment { variables = { DDB_TABLE = aws_dynamodb_table.uploads.name } }
    }    

    resource 

