resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = var.elasticache_name
  subnet_ids = [var.subnet_ids[0], var.subnet_ids[1], var.subnet_ids[2]]
}

resource "aws_security_group" "elasticache_security_group" {
  name = "elasticache_security_group"
  tags = {
    Name = "elasticache_security_group"
  }
}

resource "aws_security_group_rule" "allow_tls_ipv4" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elasticache_security_group.id
}

resource "aws_security_group_rule" "allow_all_traffic_ipv4" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elasticache_security_group.id
}

resource "aws_elasticache_replication_group" "epoch_app_elasticache" {
  replication_group_id = var.elasticache_name
  description          = "Epoch App ElastiCache Redis Cluster"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = "cache.t4g.micro"

  num_node_groups         = 2
  replicas_per_node_group = 0

  port                 = 6379
  parameter_group_name = "default.redis7.cluster.on"
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids   = [var.security_group_id[0], var.security_group_id[1], aws_security_group.elasticache_security_group.id]

  automatic_failover_enabled = true
  multi_az_enabled           = false

  transit_encryption_enabled = false
  at_rest_encryption_enabled = true

  apply_immediately = true
}