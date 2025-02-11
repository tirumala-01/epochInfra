resource "aws_ecs_cluster" "epoch_app_cluster" {
  name = var.epoch_app_cluster_name
}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_subnet" "subnet_d" {
  vpc_id            = aws_default_vpc.default_vpc.id
  availability_zone = var.availability_zones[0]
  cidr_block        = cidrsubnet(aws_default_vpc.default_vpc.cidr_block, 4, 6)

  tags = {
    Name = "subnet-d"
  }
}

resource "aws_subnet" "subnet_e" {
  vpc_id            = aws_default_vpc.default_vpc.id
  availability_zone = var.availability_zones[1]
  cidr_block        = cidrsubnet(aws_default_vpc.default_vpc.cidr_block, 4, 7)

  tags = {
    Name = "subnet-e"
  }
}

resource "aws_subnet" "subnet_f" {
  vpc_id            = aws_default_vpc.default_vpc.id
  availability_zone = var.availability_zones[2]
  cidr_block        = cidrsubnet(aws_default_vpc.default_vpc.cidr_block, 4, 8)

  tags = {
    Name = "subnet-f"
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  name = "load_balancer_security_group"
  tags = {
    Name = "load_balancer_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.load_balancer_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.load_balancer_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_alb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"
  subnets = [
    "${aws_subnet.subnet_d.id}",
    "${aws_subnet.subnet_e.id}",
    "${aws_subnet.subnet_f.id}"
  ]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_alb_target_group" "target_group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = var.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "ssm_access" {
  name   = "ecs-ssm-access"
  policy = data.aws_iam_policy_document.ssm_access_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ssm_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "epoch_app_log_group" {
  name              = "/ecs/${var.epoch_app_task_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ECSCloudWatchLogsPolicy"
  description = "Allows ECS tasks to write logs to CloudWatch"

  policy = data.aws_iam_policy_document.cloudwatch_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_logs_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}

resource "aws_ecs_task_definition" "epoch_app_task" {
  family                   = var.epoch_app_task_famliy
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.epoch_app_task_name}",
      "image": "${data.aws_ecr_image.epoch_app_image.id}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.epoch_app_log_group.name}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
      },
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}




resource "aws_security_group" "service_security_group" {
  name = "service_security_group"
  tags = {
    Name = "service_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "service_sg_ingress" {
  security_group_id            = aws_security_group.service_security_group.id
  referenced_security_group_id = aws_security_group.load_balancer_security_group.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "service_sg_egress" {
  security_group_id = aws_security_group.service_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



resource "aws_ecs_service" "epoch_app_service" {
  name            = var.epoch_app_service_name
  cluster         = aws_ecs_cluster.epoch_app_cluster.id
  task_definition = aws_ecs_task_definition.epoch_app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.epoch_app_task.family
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = ["${aws_subnet.subnet_d.id}", "${aws_subnet.subnet_e.id}", "${aws_subnet.subnet_f.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}