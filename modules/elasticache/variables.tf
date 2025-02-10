variable "elasticache_name" {
  description = "ElastiCache Cluster Name"
  type        = string
}

variable "subnet_ids" {
  description = "subnet ids"
  type        = list(string)
}

variable "security_group_id" {
  description = "security group id"
  type        = list(string)
}