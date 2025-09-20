provider "aws" { 
    region = var.aws_region
}

locals {
    project = var.project_name
    env = var.env
    bucket_name = var.bucket_name != "" ? var.bucket_name : lower(replace("${local.project}-${local-env}-uploads, " ", "-"))
    ddb_table = var.ddb_table_name != "" ? var.ddb.table_name : "${local.project}-${local.env}-uploads"
    lambda_prefix = "${local.project}-${local.env}"
}