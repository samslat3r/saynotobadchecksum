# Get current account info
data "aws_caller_identity" "current" {}

locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
  # Hardcode the OIDC provider ARN to avoid permission issues during plan
  github_oidc_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# Trust policy for repo/branch to assume role via OIDC
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.owner}/${var.repo}:ref:refs/heads/${var.branch}"
      ]
    }
  }
}

resource "aws_iam_role" "gha" {
  name               = "${var.name_prefix}-gha-oidc"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}



# Default inline policy for bootstraping

data "aws_iam_policy_document" "gha_perm" {
  statement {
    actions = [
      "s3:*",
      "dynamodb:*",
      "lambda:*",
      "logs:*",
      "apigateway:*",
      "iam:PassRole",
      "iam:ListOpenIDConnectProviders",
      "iam:GetOpenIDConnectProvider",

      # Secrets injection step

      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource"
    ]
    resources = ["*"]


  }
}

# Optional override of the inline policy
locals {
  inline_policy_json = var.policy_json != "" ? var.policy_json : data.aws_iam_policy_document.gha_perm.json
}

resource "aws_iam_role_policy" "gha_perm" {
  role   = aws_iam_role.gha.id
  policy = data.aws_iam_policy_document.gha_perm.json
}


