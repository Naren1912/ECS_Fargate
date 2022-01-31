terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
}

data "aws_ssm_parameters_by_path" "VpcIdSSM" {
  count = "${var.VpcIdSSM == "" ? 0 : 1}"
  path = var.VpcIdSSM
}

data "aws_ssm_parameters_by_path" "PrivateSubnetIdSSM" {
  count = "${var.PrivateSubnetIdSSM == "" ? 0 : 1}"
  path = var.PrivateSubnetIdSSM
}

data "aws_ssm_parameters_by_path" "PublicSubnetIdSSM" {
  count = "${var.PublicSubnetIdSSM == "" ? 0 : 1}"
  path = var.PublicSubnetIdSSM
}

data "aws_ssm_parameters_by_path" "AcmCertificateArnSSM" {
  count = "${var.AcmCertificateArnSSM == "" ? 0 : 1}"
  path = var.AcmCertificateArnSSM
}

module "ecs_cluster" {
  source = "anrim/ecs/aws//modules/cluster"
  name = "app-dev"
  vpc_id      = var.VpcIdSSM  == ""  ?  var.VpcId : data.aws_ssm_parameters_by_path.VpcIdSSM
  vpc_subnets = var.PrivateSubnetIdsSSM  == ""  ?  var.PrivateSubnetIds : data.aws_ssm_parameters_by_path.PrivateSubnetIdsSSM
  tags        = {
    Owner = "Narendra"
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
  source = "anrim/ecs/aws//modules/alb"
  name            = "app-dev"
  host_name       = "app"
  domain_name     = "example.com"
  certificate_arn = var.AcmCertificateArnSSM  == ""  ?  var.AcmCertificateArn : data.aws_ssm_parameters_by_path.AcmCertificateArnSSM
  tags            = {
    Owner = "Narendra"
  }
  vpc_id      = var.VpcIdSSM  == ""  ?  var.VpcId : data.aws_ssm_parameters_by_path.VpcIdSSM
  vpc_subnets = var.PublicSubnetIdsSSM  == ""  ?  var.PublicSubnetIds : data.aws_ssm_parameters_by_path.PublicSubnetIdsSSM
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
    Owner = "Narendra"
  }
}
