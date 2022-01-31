terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
}

data "aws_ssm_parameters_by_path" "VpcIdSSM" {
  count = var.VpcIdSSM ? == "" 0 : 1
  path = var.VpcIdSSM
}

module "ecs_cluster" {

  name = "app-dev"
  vpc_id      = var.VpcIdSSM  == ""  ?  var.VpcId : data.aws_ssm_parameters_by_path.VpcIdSSM
  vpc_subnets = var.PrivateSubnetIds
  tags        = {
    Environment = "dev"
    Owner = "me"
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "app-dev"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = env_type == "dev" ? "FARGATE_SPOT" : "FARGATE" 
    }
  ]

  tags = {
    Environment = env_type == "dev" ? "Development" : "Production"
  }
}
    
resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = "app-dev"

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

module "alb" {

  name            = "app-dev"
  host_name       = "app"
  domain_name     = "example.com"
  certificate_arn = var.AcmCertificateArn
  tags            = {
    Environment = "dev"
    Owner = "me"
  }
  vpc_id      = var.VpcId
  vpc_subnets = var.PublicSubnetIds
}

resource "aws_ecs_task_definition" "app" {
  family = "app-dev"
  container_definitions = <<EOF
[
  {
    "name": "httpd",
    "image": "httpd",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "app-dev-nginx",
        "awslogs-region": "us-east-1"
      }
    },
    "memory": 128,
    "cpu": 100
  }
]
EOF
}

module "ecs_service_app" {
  source = "anrim/ecs/aws//modules/service"

  name = "app-dev"
  alb_target_group_arn = "${module.alb.target_group_arn}"
  cluster              = "${module.ecs_cluster.cluster_id}"
  container_name       = "nginx"
  container_port       = "80"
  log_groups           = ["app-dev-nginx"]
  task_definition_arn  = "${aws_ecs_task_definition.app.arn}"
  tags                 = {
    Environment = "dev"
    Owner = "me"
  }
}}
