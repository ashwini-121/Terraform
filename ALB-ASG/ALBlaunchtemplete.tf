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
