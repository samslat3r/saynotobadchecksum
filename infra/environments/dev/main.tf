terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}

provider "aws" { region = var.aws_region }

data "aws_caller_identity" "current" {}

locals {
  project     = var.project_name
  env         = var.env
  bucket_name = var.bucket_name != "" ? var.bucket_name : lower(replace("${local.project}-${local.env}-uploads", " ", "-"))
  ddb_table   = var.ddb_table_name != "" ? var.ddb_table_name : "${local.project}-${local.env}-uploads"
  name_prefix = "${local.project}-${local.env}"
  tags = {
    Project = local.project
    Env     = local.env
  }
}

module "s3" {
  source      = "../../../modules/s3_uploads"
  bucket_name = local.bucket_name
  tags        = { Project = local.project, Env = local.env }
}

module "ddb" {
  source     = "../../../modules/ddb_uploads"
  table_name = local.ddb_table
  tags       = { Project = local.project, Env = local.env }
}

# Secrets are created EMPTY; CI injects values post-apply

module "secrets" {
  source      = "../../../modules/secrets"
  name_prefix = local.name_prefix
}

module "iam" {
  source        = "../../../modules/iam_lambda"
  name_prefix   = local.name_prefix
  s3_bucket_arn = module.s3.bucket_arn
  ddb_table_arn = module.ddb.table_arn
  secret_arns   = [module.secrets.vt_secret_arn, module.secrets.presign_secret_arn]
}

module "lambda_presign" {
  source   = "../../../modules/lambda_function"
  name     = "${local.name_prefix}-presign"
  role_arn = module.iam.lambda_role_arn
  filename = var.lambda_artifacts.presign
  timeout  = 10
  env = {
    UPLOADS_BUCKET    = module.s3.bucket_name
    USE_API_KEY       = "true"
    PRESIGN_SECRET_ID = module.secrets.presign_secret_id
  }
}

module "lambda_list" {
  source   = "../../../modules/lambda_function"
  name     = "${local.name_prefix}-listfiles"
  role_arn = module.iam.lambda_role_arn
  filename = var.lambda_artifacts.list_files
  timeout  = 10
  runtime  = "python3.12"
  env = {
    DDB_TABLE = module.ddb.table_name
  }
}

module "lambda_process" {
  source      = "../../../modules/lambda_function"
  name        = "${local.name_prefix}-process-upload"
  role_arn    = module.iam.lambda_role_arn
  filename    = var.lambda_artifacts.process_upload
  timeout     = 60
  runtime     = "python3.12"
  memory_size = 1024
  env = {
    DDB_TABLE    = module.ddb.table_name
    VT_SECRET_ID = module.secrets.vt_secret_id
  }
}

module "api" {
  source = "../../../modules/apigw_http"
  name   = "${local.name_prefix}-api"
  routes = [
    {
      method      = "POST"
      path        = "/presign"
      lambda_arn  = module.lambda_presign.lambda_arn
      lambda_name = module.lambda_presign.name
    },
    {
      method      = "GET"
      path        = "/files"
      lambda_arn  = module.lambda_list.lambda_arn
      lambda_name = module.lambda_list.name
    }
  ]
}

module "s3_notifications" {
  source      = "../../../modules/s3_lambda_notification"
  bucket_id   = module.s3.bucket_id
  bucket_arn  = module.s3.bucket_arn
  lambda_arn  = module.lambda_process.lambda_arn
  lambda_name = module.lambda_process.name
  events      = ["s3:ObjectCreated:*"]
}

module "gha_oidc" {
  source      = "../../../modules/iam_oidc_github"
  name_prefix = local.name_prefix
  owner       = var.github_owner
  repo        = var.github_repo
  branch      = var.github_branch
}

module "web_s3" {
  source = "../../../modules/s3-static-site"

  bucket_name    = "saynotobadchecksum-web-dev-${data.aws_caller_identity.current.account_id}"
  cloudfront_arn = "" # Set after CloudFront is created
  cors_origins   = ["*"]

  tags = local.tags
}

module "cloudfront" {
  source = "../../../modules/cloudfront"

  name_prefix                 = local.name_prefix
  bucket_regional_domain_name = module.web_s3.bucket_regional_domain_name
  bucket_id                   = module.web_s3.bucket_id
  price_class                 = "PriceClass_100"

  tags = local.tags
}

# Update S3 bucket policy after CloudFront is created
resource "aws_s3_bucket_policy" "web_cloudfront" {
  bucket = module.web_s3.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.web_s3.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [module.cloudfront, module.web_s3]
}