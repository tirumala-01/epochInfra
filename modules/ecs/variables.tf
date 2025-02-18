variable "epoch_app_cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR Repo Name"
  type        = string
}

variable "availability_zones" {
  description = "us-east-1 AZs"
  type        = list(string)
}

variable "application_load_balancer_name" {
  description = "ALB Name"
  type        = string
}

variable "target_group_name" {
  description = "ALB Target Group Name"
  type        = string
}

variable "container_port" {
  description = "Container Port"
  type        = number
}

variable "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string
}

variable "ecs_task_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string
}

variable "epoch_app_task_famliy" {
  description = "ECS Task Family"
  type        = string
}


variable "epoch_app_task_name" {
  description = "ECS Task Name"
  type        = string
}


variable "ecr_repo_url" {
  description = "ECR Repo URL"
  type        = string
}

variable "epoch_app_service_name" {
  description = "ECS Service Name"
  type        = string
}


variable "redis_url" {
  type        = string
  sensitive   = true
  description = "Redis URL"
}


variable "rds_url" {
  type        = string
  sensitive   = true
  description = "Redis URL"
}