output "rds_endpoint" {
  value = aws_db_instance.epoch_app_rds.endpoint
}

output "rds_connection_url" {
  value = "postgresql://${local.rds_credentials.username}:${local.rds_credentials.password}@${aws_db_instance.epoch_app_rds.endpoint}/${var.epoch_app_rds_db_name}"
}