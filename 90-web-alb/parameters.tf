resource "aws_ssm_parameter" "web_alb_listener_arn" {
    type = "String"
    name = "/${var.project_name}/${var.environment}/web_alb_listener_arn"
    value = aws_lb_listener.https.arn
  
}