data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_ecr_image" "epoch_app_image" {
  image_tag       = "latest"
  repository_name = var.ecr_repo_name
}


data "aws_iam_policy_document" "ssm_access_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = [
      "arn:aws:ssm:us-east-1:${local.account_id}:parameter/*",
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.epoch_app_log_group.arn}:*",
    ]
  }
}