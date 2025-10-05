resource "aws_apigatewayv2_api" "main" {
    name = var.name
    protocol_type = "HTTP"
}

locals {
    routes = var.routes
}

resource "aws_apigatewayv2_integration" "this" {
    for each = { for r in local.routes : "${r.method}-${r.path}" => r }
    api_id = aws_apigatewayv2_api.main.id
    integration_type = "AWS_PROXY"
    integration_uri = each.value.lambda_arn
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
    for each = { for r in local.routes : "${r.method}-${r.path}" => r }
    api_id = aws_apigatewayv2_api.main.id 
    route_key = "${each.value.method} ${each.value.path}"
    target = "integrations/${aws_apigatewayv2_integration.this["${each.value.method}-${each.value.path}"].id}"
}

resource "aws_lambda_permission" "invoke" {
    for each = { for r in local.routes : r.lambda_name => r }
    statement_id = "AllowAPIGWInvoke-${each.value.lambda_name}"
    action = "lambda:InvokeFunction"
    function_name = each.value.lambda_name 
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
    

