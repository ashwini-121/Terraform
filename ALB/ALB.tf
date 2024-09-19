#Application load balancer creation
resource "aws_lb" "Terraform-ALB" {
  name               = "Terraform-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = [var.subnet_id_1, var.subnet_id_2]
}
## Traget group creation 
resource "aws_lb_target_group" "target_alb" {
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0f4f64bbbe820043f"
  health_check {
    path     = "/health"
    port     = 80
    protocol = "HTTP"
  }
}
#### Ec2 instances attachment to target group #####
resource "aws_lb_target_group_attachment" "attachement1" {
  target_group_arn = aws_lb_target_group.target_alb.arn
  target_id        = aws_instance.ALB-ec2-a.id
  port             = 80
  depends_on = [
    aws_lb_target_group.target_alb,
    aws_instance.ALB-ec2-a,
  ]
}
resource "aws_lb_target_group_attachment" "attachement2" {
  target_group_arn = aws_lb_target_group.target_alb.arn
  target_id        = aws_instance.ALB-ec2-b.id
  port             = 80
  depends_on = [
    aws_lb_target_group.target_alb,
    aws_instance.ALB-ec2-b,
  ]
}
######## Listener creation ####
resource "aws_lb_listener" "listener_elb" {
  load_balancer_arn = aws_lb.Terraform-ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_alb.arn
  }
}
############ Outputs section##########
output "lb_dns_name" {
  description = "DNS of Load balancer"
  value       = aws_lb.Terraform-ALB.dns_name
}
