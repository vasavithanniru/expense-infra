module "mysql_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "mysql" 
    common_tags = var.common_tags 
}

module "backend_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "backend"
    common_tags = var.common_tags
}

module "frontend_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "frontend"
    common_tags = var.common_tags
}

module "bastion_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "bastion"
    common_tags = var.common_tags
}

module "ansible_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "ansible"
    common_tags = var.common_tags
}


module "app_alb_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "app_alb"
    common_tags = var.common_tags
}

module "web_alb_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "web_alb"
    common_tags = var.common_tags
}

module "vpn_sg" {
    source = "git::https://github.com/vasavithanniru/terraform-aws-security-group.git?ref=main"
    environment = var.environment
    project_name = var.project_name
    vpc_id = local.vpc_id
    sg_name = "vpn"
    common_tags = var.common_tags
}

#mysql allows connectin from backend on port 3306

resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend_sg.id
  security_group_id = module.mysql_sg.id
}

# mysql allow connection from bastion on port 3306
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id = module.mysql_sg.id
}

# backendd allows connection from app_alb on port 8080
resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.id
  security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id = module.backend_sg.id
}


#app_alb allows connectin from bastion on port 80

resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id = module.app_alb_sg.id
}

#app_alb allows connectin from bastion on port 80

resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend_sg.id
  security_group_id = module.app_alb_sg.id
}



#frontend allows connection from web_alb on port 80
resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id =  module.web_alb_sg.id
  security_group_id = module.frontend_sg.id
}


resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.id
}


resource "aws_security_group_rule" "backend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible_sg.id
  security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible_sg.id
  security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id = module.frontend_sg.id
}

resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.ansible_sg.id
}

resource "aws_security_group_rule" "vpn_public_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "app_alb_vpn_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id = module.app_alb_sg.id
}

resource "aws_security_group_rule" "backend_vpn_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "backend_vpn_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "web_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id
}

resource "aws_security_group_rule" "web_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id

}


