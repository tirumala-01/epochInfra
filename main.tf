terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket  = "mytfstate-epochapp-demo"
    key     = "infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "tf-state" {
  source      = "./modules/tf-state"
  bucket_name = local.bucket_name
}

module "ecrRepo" {
  source        = "./modules/ecr"
  ecr_repo_name = local.ecr_repo_name
}

module "ecsCluster" {
  source = "./modules/ecs"

  epoch_app_cluster_name = local.epoch_app_cluster_name
  availability_zones     = local.availability_zones

  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group_name
  container_port                 = local.container_port

  ecs_task_execution_role_name = local.ecs_task_execution_role_name
  ecs_task_role_name           = local.ecs_task_role_name

  epoch_app_task_famliy = local.epoch_app_task_famliy
  epoch_app_task_name   = local.epoch_app_task_name

  ecr_repo_url           = module.ecrRepo.repository_url
  epoch_app_service_name = local.epoch_app_service_name
  ecr_repo_name          = local.ecr_repo_name

}

module "elastiCache" {
  source            = "./modules/elasticache"
  elasticache_name  = local.elasticache_name
  subnet_ids        = [module.ecsCluster.subnet_d_id, module.ecsCluster.subnet_e_id, module.ecsCluster.subnet_f_id]
  security_group_id = [module.ecsCluster.load_balancer_security_group_id, module.ecsCluster.service_security_group_id]
}