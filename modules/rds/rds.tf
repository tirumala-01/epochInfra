data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = var.rds_credentials_secret_id
}

locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)
}

resource "aws_security_group" "rds_security_group" {
  name = "rds_security_group"
  tags = {
    Name = "rds_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "epoch_app_rds" {
  allocated_storage      = 20
  db_name                = var.epoch_app_rds_db_name
  identifier             = var.epoch_app_rds_identifier
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t4g.micro"
  username               = local.rds_credentials.username
  password               = local.rds_credentials.password
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}