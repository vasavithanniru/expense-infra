resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn"
  public_key = file("~/vpn/openvpn.pub")  #importing the private key
  # ~/vpn/openvpn.pub
}

module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  key_name = aws_key_pair.openvpn.key_name
  name = local.resource_name
  ami = data.aws_ami.vasavi-devops.id

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.vpn_sg_id]
  #creating vpn in public subnet
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    var.vpn_tags,
    {
        Name = local.resource_name
    }

  )
}