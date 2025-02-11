locals {
  bucket_name = "mytfstate-epochapp-demo"

  ecr_repo_name          = "epoch-app-ecr-repo"
  epoch_app_cluster_name = "epoch-app-cluster"
  availability_zones     = ["us-east-1d", "us-east-1e", "us-east-1f"]

  application_load_balancer_name = "epoch-app-alb"
  target_group_name              = "epoch-alb-tg"
  container_port                 = 80

  ecs_task_execution_role_name = "epoch-app-task-execution-role"
  ecs_task_role_name           = "epoch-app-ecs-task-role-policy"

  epoch_app_task_famliy = "epoch-app-task"
  epoch_app_task_name   = "epoch-app-task"

  epoch_app_service_name = "epoch-app-service"

  elasticache_name = "epoch-app-elasticache"
}