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

resource "aws_autoscaling_group" "TerraformASGroup" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  name               = "TerraformASGroup"
  health_check_type  = "EC2"
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  target_group_arns = [aws_lb_target_group.target_alb.arn]
  tag {
    key                 = "ASG"
    value               = "AWS"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.TerraformASG.id
    version = "$Latest"
  }
}
resource "aws_autoscaling_policy" "TerraformASGrouppolicy" {
  name                   = "TerraformASGrouppolicy"
  autoscaling_group_name = aws_autoscaling_group.TerraformASGroup.id
  #  adjustment_type = "changeInCapacity"
  #  scaling_adjustment = 1
  policy_type = "TargetTrackingScaling"
  #  cooldown = 50
  estimated_instance_warmup = 10
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10.0
  }
}
