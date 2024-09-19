resource "aws_instance" "ALB-ec2-a" {
  #count = 1
  ami                         = "${var.ami_id}"
  instance_type               = var.instance_type
  key_name                    = var.ami_key_pair_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id_1
  associate_public_ip_address = true
  tags = {
    name = "EC2-A"
    Name = "ALB_1"
  }
  user_data = <<-EOF
             #!/bin/bash -xe
             sudo -i
             yum update -y
             yum install -y httpd
             echo "Healthy" > /var/www/html/index.html
             systemctl start httpd
             systemctl enable httpd
             EOF
}
resource "aws_instance" "ALB-ec2-b" {
  ami                         = var.ami_id
  #count = 1
  instance_type               = var.instance_type
  
  key_name                    = var.ami_key_pair_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id_2
  associate_public_ip_address = true
  
  tags = {
    name = "EC2-B"
    Name = "ALB_2"
  }
  user_data = <<-EOF
             #!/bin/bash -xe
             sudo -i
             yum update -y
             yum install -y httpd
             echo "UnHealthy" > /var/www/html/index.html
             systemctl start httpd
             systemctl enable httpd
             EOF
}

