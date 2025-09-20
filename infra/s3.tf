resource "aws_s3_bucket" "uploads" {
    bucket  = local.bucket_name
    force_destroy = false
    tags = {Project = local.project, Env = local.env }

}

resource "aws_s3_bucket_public_access_block" "uploads" { 
    bucket  = aws_s3_bucket.uploads.id
    block_public_acls = true
    block_policy_acls = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "uploads" {
    bucket = aws_s3_bucket.uploads.id
    versioning_configuration { status = Enabled }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
    bucket = aws_s3_bucket.uploads.id
    rule {
        apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
    }
}