resource "aws_secretsmanager_secret" "vt" {
  name = "${var.name_prefix}-virustotal"
}

resource "aws_secretsmanager_secret_version" "vtv" {
  secret_id     = aws_secretsmanager_secret.vt.id
  secret_string = jsonencode({ VT_API_KEY = var.vt_api_key })
}

resource "aws_secretsmanager_secret" "presign" {
  name = "${var.name_prefix}-presign"
}

resource "aws_secretsmanager_secret_version" "presignv" {
  secret_id     = aws_secretsmanager_secret.presign.id
  secret_string = jsonencode({ PRESIGN_API_KEY = var.presign_api_key })
}



