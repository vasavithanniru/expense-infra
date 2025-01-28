module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = var.ami

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.frontend_sg_id]
  #creating bastion in public subnet
  subnet_id              = local.public_subnet_id

  tags = merge (
    var.common_tags,
    var.frontend_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "null_resource" "frontend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.frontend.id
  }

  # Bootstrap script can run on any instance of the cluster
  connection {
    host = module.frontend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  # Copies all files and folders in frontend.sh to /tmp/frontend.sh
  provisioner "file" {
    source      = "${var.frontend_tags.Component}.sh"
    destination = "/tmp/frontend.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/frontend.sh",
      "sudo sh /tmp/frontend.sh ${var.frontend_tags.Component} ${var.environment}"
    ]
  }
}

#stop frontend instance
resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state       = "stopped"
  depends_on = [ null_resource.frontend ]
}

# #take AMI from frontend
resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = module.frontend.id
  depends_on = [ aws_ec2_instance_state.frontend ]
}

# #delete old frontend server
resource "null_resource" "frontend_delete" {
  triggers = {
    instance_id = module.frontend.id
  }
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.frontend.id}"
  }
    depends_on = [ aws_ami_from_instance.frontend ]
}

 # creating lb-target-group
resource "aws_lb_target_group" "frontend" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

   health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
    #approximate amount of time, in seconds, between health checks of an individual target
    interval = 5
    #The amount of time, in seconds, during which no response means a failed health check
    timeout = 4
  }
}

#creating launch template
resource "aws_launch_template" "frontend" {
  name = local.resource_name
  image_id = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  update_default_version = true
  vpc_security_group_ids = [local.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }
}

#creating auto scalling group
resource "aws_autoscaling_group" "frontend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2       #starting of the auto scalling group
  target_group_arns = [aws_lb_target_group.frontend.arn]
 
  #auto scalling using launch templates
  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  #using public subnet for frontend
  vpc_zone_identifier       = [local.public_subnet_id]
  
  #  rolling update, if launch template changed version will change, then auto scalling will be updated 
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }
  
  #if instances are not healthy within 15 mins, auto scalling will delete that instance
  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "Expense"
    propagate_at_launch = false
  }
}

#auto scalling policy
resource "aws_autoscaling_policy" "frontend" {
  name                   = local.resource_name
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }  
}

# alb_listener_rules 
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = local.web_alb_listener_arn
  priority     = 100  # low priority will be evaluated first

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["expense-${var.environment}.${var.zone_name}"]   #expense-dev.vasavi.online
    }
  }
}
