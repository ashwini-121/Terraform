provider "aws" {
  region     = "us-east-1"
  access_key = "AKIARP32OFSJQ74I7TF4"
  secret_key = "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"

}
resource "aws_instance" "ec2_with_tfvars" {
  ami                         = var.image_id
  instance_type               = var.itype
  vpc_security_group_ids      = [aws_security_group.web-sg.id]
  availability_zone           = var.zone
  associate_public_ip_address = false

}
resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1a"
  size              = 8

  tags = {
    Name = "HelloWorld"
  }
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.ec2_with_tfvars.id
}
resource "aws_security_group" "web-sg" {
  name   = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}
