module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = "ami-09c813fb71547fc4f"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]
  #creating bastion in public subnet
  subnet_id              = local.public_subnet_ids

  tags = merge (
    var.common_tags,
    var.bastion_tags,
    {
        Name = local.resource_name
    }

  )
}