data "aws_iam_policy_document" "assume" {
    statement {
        actions = ["sts:AssumeRole"]
        principals { type = "Service", identifiers = ["lambda.amazonaws.com"] }
    }
}


resource "aws_iam_role" "lambda" {
    name = "${var.name_prefix}-lambda-role"
    assume_role_policy = data.aws_iam_policy_document.assume.json
}


resource "aws_iam_role_policy" "inline" {
    name = "${var.name_prefix}-lambda-policy"
    role = aws_iam_role.lambda.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            { Effect = "Allow", Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource = "*" },
            { Effect = "Allow", Action = ["s3:GetObject","s3:PutObject","s3:DeleteObject"], Resource = ["${var.s3_bucket_arn}/*"] },
            { Effect = "Allow", Action = ["dynamodb:PutItem","dynamodb:Scan","dynamodb:GetItem","dynamodb:UpdateItem"], Resource = [var.ddb_table_arn] },
            { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = var.secret_arns }
        ]
    })
}
