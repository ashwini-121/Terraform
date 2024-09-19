
resource "aws_launch_template" "TerraformASG" {
  # name_prefix            = "TerraformASG"
  name                   = "ASG-LT"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ami_key_pair_name
  vpc_security_group_ids = [var.security_group_id]
  #vpc_security_group_ids = ["sg-0ad30a664c1e052d4"]
  tag_specifications {
    resource_type = "instance"
  tags = {
    Name     = "terraformec2"
    Provider = "aws"
  }
  }
  user_data = base64encode(templatefile("C:/Users/005303/Desktop/Terraform/Autoscaling/userdata.sh", {}))
}

resource "aws_autoscaling_group" "TerraformASGroup" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  name               = "TerraformASGroup"
  health_check_type  = "EC2"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
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
  estimated_instance_warmup = 60
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10.0
  }
}