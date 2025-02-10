resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = var.elasticache_name
  subnet_ids = [var.subnet_ids[0], var.subnet_ids[1], var.subnet_ids[2]]
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
  security_group_ids   = [var.security_group_id[0], var.security_group_id[1]]

  automatic_failover_enabled = true
  multi_az_enabled           = false

  transit_encryption_enabled = false
  at_rest_encryption_enabled = true

  apply_immediately = true
}