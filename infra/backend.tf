terraform {
  backend "s3" {
    # These values will be provided via backend config file or CLI args
    # bucket         = "your-terraform-state-bucket"
    # key            = "path/to/state/file"
    # region         = "us-west-2"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}