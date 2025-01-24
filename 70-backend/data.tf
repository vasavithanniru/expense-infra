data "aws_ami" "vasavi-devops" {

  most_recent      = true
  owners      = ["278768175210"] 

  filter {
    name   = "name"
    values = ["vasavi-devops"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ssm_parameter" "backend_sg_id" {
    name = "/${var.project_name}/${var.environment}/backend_sg_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project_name}/${var.environment}/vpc_id"
}



