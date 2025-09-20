data "aws_iam_policy_document" "lambda_assume" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
    }

    resource "aws_iam_role" "lambda_role" {
        name = "${local.lambda_prefix}-lambda-policy"
        role = aws_iam_role.lambda_role.id 
        policy = jsonencode({
            version = "2021-10-17"
            statement = [
                {
                    Effect = "Allow"
                    Action = [ "logs:"logs:CreateLogGroup",
                               "logs:CreateLogStream",
                               "logs:PutLogEvents" ]
                    Resource = "*"
                    },
                    {
                    Effect = "Allow"
                    Action = "[ "s3:PutObject",
                               "s3:GetObject",
                               "s3:ListBucket",
                               "s3:DeleteObject" ],
                    Resource = [ "${aws_s3_bucket;uploads.arn}/*]
                    },
                    {
                    Effect = "Allow"
                    Action = [ "dynamodb:PutItem",
                               "dynamodb:GetItem",
                               "dynamodb:UpdateItem",
                               "dynamodb:Scan",
                               "dynamodb:DeleteItem" ]
                    Resource = [ aws_dynamodb_table_uploads.arn ]
                    },
                    {
                    Effect = "Allow"
                    Action = ["secretsmanager:GetSecretValue"],
                    Resource = [aws_secretsmanager_secret.vt.arn, aws_secretsmanager_secret.presign.arn]
                }
            ]
        })
    }                        