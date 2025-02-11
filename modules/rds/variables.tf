variable "rds_credentials_secret_id" {
  description = "The name of the AWS Secrets Manager secret that contains the RDS credentials"
  type        = string
}

variable "epoch_app_rds_db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "epoch_app_rds_identifier" {
  description = "The identifier of the RDS database"
  type        = string
}