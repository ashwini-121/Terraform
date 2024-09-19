resource "aws_instance" "demo-ec2" {
  ami                         = "ami-07761f3ae34c4478d"
  instance_type               = "t2.micro"
  key_name                    = "demo"
  vpc_security_group_ids      = [aws_security_group.web-sg.id]
  subnet_id                   = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  tags = {
    name = "EC2-1"
  }
  user_data = <<-EOF

             #!/bin/bash

             sudo yum update

             sudo yum install -y nginx

             sudo systemctl start nginx

             sudo systemctl enable nginx

             echo '<!doctype html>

             <html lang="en"><h1>Home page!</h1></br>

             <h3>(Instance A)</h3>

             </html>' | sudo tee /var/www/html/index.html

             EOF
}
