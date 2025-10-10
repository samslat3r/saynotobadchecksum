variable "project_name" {
    type = string 
}

variable "env" {
    type = string 
}

variable "aws_region" {
    type = string 
}

variable "bucket_name" {
    type = string
    default = ""

}

variable "ddb_table_name" { 
    type = string
    default = ""
}

variable "lambda_artifacts" {
    description = "Paths to built lambda zips"
    type = object({
      presign = string
      list_files = string
      process_upload = string
    })
    default = {
        presign = "../../../lambdas"
        list_files = "../../../lambdas"
        process_upload = "../../../lambdas"
    }
}

# OIDC Metadata (not secrets)

variable github_owner {
    type = string
    default = "samslat3r"  
}

variable github_repo {
    type = string
    default = "saynotobadchecksum"
}

variable github_branch {
    type = string
    default = "master"
}