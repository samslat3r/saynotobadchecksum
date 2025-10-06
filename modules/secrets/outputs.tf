output "vt_secret_id" {
  description = "VT Secret id"
  value       = aws_secretsmanager_secret.vt.id
}

output "vt_secret_arn" {
  description = "VT Secret ARN"
  value       = aws_secretsmanager_secret.vt.arn
}

output "presign_secret_id" {
  description = "Presign secret id"
  value       = aws_secretsmanager_secret.presign.id
}

output "presign_secret_arn" {
  description = "Presign secret ARN"
  value       = aws_secretsmanager_secret.presign.arn
}