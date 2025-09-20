terraform {
    required_version ">= "1.6.0"
    required_providers {
        aws = {
            "hashicorp/aws"
            version = ">= 5.0"
        }
        archive = {
            source = "hashicorp/arcive"
            version=">=2.4"
        }
    }
}