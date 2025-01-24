#this is private lb, only vpn/bastion can access

module "app_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal = true

  name    = "${local.resource_name}-app-alb" #expens-dev-app-alb
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids
  create_security_group = false
  security_groups = [local.app_alb_sg_id]
  enable_deletion_protection = false
  tags = merge(
    var.common_tags,
    var.app_alb_tags
  )
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = module.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, i am from application alb</h1>"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "*.app-${var.environment}" #<something>.app-dev.vasavi.online - if we hit this we can get response through bastion
      type    = "A"
      alias   = {
        name    = module.app_alb.dns_name
        zone_id = module.app_alb.zone_id   #this belongs to ALB internal hosted zone
      }
      allow_overwrite = true
    }
  ]
}
 
  