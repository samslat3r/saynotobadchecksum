resource "aws_secretsmanager_secret" "vt" {
  name                    = "${var.name_prefix}-vt-api-key"
  description             = "VirusTotal API Key (Injected via Terraform in CI)"
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "presign" {
  name                    = "${var.name_prefix}-presign"
  description             = "Presign API Key (Injected via Terraform in CI)"
  kms_key_id              = var.kms_key_id != "" ? var.kms_key_id : null
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}