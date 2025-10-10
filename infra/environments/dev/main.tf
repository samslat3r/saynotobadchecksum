terraform {
    required_version = ">= 1.6.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0.0"
        }
        archive = {
            source  = "hashicorp/archive"
            version = ">= 2.0.0"
        }
    }
}

provider "aws" { region = var.aws_region }

locals {
    project = var.project_name
    env = var.env
    bucket_name = var.bucket_name != "" ? var.bucket_name : lower(replace("${local.project}-${local.env}-uploads", " ", "-"))
    ddb_table = var.ddb_table_name != "" ? var.ddb_table_name : "${local.project}-${local.env}-uploads"
    name_prefix = "${local.project}-${local.env}" 
}

module "s3" {
    source = "../../../modules/s3_uploads"
    bucket_name = local.bucket_name
    tags = { Project = local.project, Env = local.env }
}

module "ddb" {
    source = "../../../modules/ddb_uploads"
    table_name = local.ddb_table
    tags = { Project = local.project, Env = local.env }
}

# Secrets are created EMPTY; CI injects values post-apply

module "secrets" {
    source = "../../../modules/secrets"
    name_prefix = local.name_prefix
}

module "iam" {
    source = "../../../modules/iam_lambda"
    name_prefix = local.name_prefix
    s3_bucket_arn = module.s3.bucket_arn
    ddb_table_arn = module.ddb.table_arn
    secret_arns = [module.secrets.vt_secret_arn, module.secrets.presign_secret_arn]
}

module lambda_presign { 
    source = "../../../modules/lambda_function"
    name = "${local.name_prefix}-presign"
    role_arn = module.iam.lambda_role_arn
    filename = var.lambda_artifacts.presign
    timeout = 10
    env = {
        UPLOADS_BUCKET = module.s3.bucket_name
        USE_API_KEY = "true"
        PRESIGN_SECRET_ID = module.secrets.presign_secret_id
    }
}

module "lambda_list" {
    source = "../../../modules/lambda_function"
    name = "${local.name_prefix}-list-files"
    role_arn = module.iam.lambda_role_arn
    filename = var.lambda_artifacts.list_files
    timeout = 10
    runtime = "python3.12"
    env = {
        DDB_TABLE = module.ddb.table_name
    }
}

module "lambda_process" {
    source = "../../../modules/lambda_function"
    name = "${local.name_prefix}-process-upload"
    role_arn = module.iam.lambda_role_arn
    filename = var.lambda_artifacts.process_upload
    timeout = 60
    runtime = "python3.12"
    memory_size = 1024
    env = {
        DDB_TABLE = module.ddb.table_name
        VT_SECRET_ID = module.secrets.vt_secret_id
    }
}

module "api" {
    source = "../../../modules/apigw_http"
    name = "${local.name_prefix}-api"
    routes = [
        {
            method = "POST"
            path = "/presign"
            lambda_arn = module.lambda_presign.lambda_arn
            lambda_name = module.lambda_presign.name
        },
        {
            method = "GET"
            path = "/files"
            lambda_arn = module.lambda_list.lambda_arn
            lambda_name = module.lambda_list.name
        }
    ]
}

module "s3_notifications" { 
    source = "../../../modules/s3_notifications"
    bucket_name = module.s3.bucket_name
    bucket_arn = module.s3.bucket_arn
    lambda_arn = module.lambda_process.lambda_arn
    lambda_name = module.lambda_process.name 
}