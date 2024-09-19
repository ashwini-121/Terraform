
resource "aws_instance" "terraform" {
#   count         = 1
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  availability_zone = "us-east-1a"
  key_name = "${var.ami_key_pair_name}"
  vpc_security_group_ids = [var.security_group_id]
  #vpc_security_group_ids = ["sg-0ad30a664c1e052d4"]
  subnet_id   = "${var.subnet_id}"
  user_data = <<-EOL
     #!/bin/bash
     sudo -i
     yum update -y
     yum install httpd -y
     systemctl start httpd
     systemctl enable httpd
     cd /var/www/html
     touch test.html
   EOL

  tags = {
    Name = "terraformec2"
    Provider = "aws"
  }
}