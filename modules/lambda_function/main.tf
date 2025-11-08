locals {
  use_archive  = var.source_dir != ""
  package_path = var.source_dir != "" ? "${path.module}/.dist/${var.name}.zip" : var.filename
}

# Build a zip only when source_dir is provided - added for bootstrap terraform plan
data "archive_file" "zip" {
  count       = local.use_archive ? 1 : 0
  type        = "zip"
  source_dir  = var.source_dir
  output_path = local.package_path
  excludes    = var.excludes
}


resource "aws_lambda_function" "main" {
  function_name    = var.name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  filename         = local.package_path
  source_code_hash = local.use_archive ? data.archive_file.zip[0].output_base64sha256 : filebase64sha256(var.filename)
  timeout          = var.timeout
  memory_size      = var.memory_size
  environment { variables = var.env }

  lifecycle {
    precondition {
      condition     = local.use_archive || (var.filename != "")
      error_message = "Either source_dir or filename must be provided."
    }
  }
}