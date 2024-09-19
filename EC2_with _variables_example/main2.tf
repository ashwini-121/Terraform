provider "aws" {
region = lookup(var.awsprops, "region")
access_key = "A"
secret_key = ""
}
resource "aws_instance" "my_demo" {
ami = lookup(var.awsprops, "ami")
instance_type = lookup(var.awsprops, "itype")
subnet_id = lookup(var.awsprops, "subnet") 
associate_public_ip_address = lookup(var.awsprops, "publicip")
vpc_security_group_ids = [
aws_security_group.default.id
]
root_block_device {
delete_on_termination = true
volume_size = 8
volume_type = "gp2"
}
tags = {
Name ="SERVER01"
Environment = "DEV"
OS = "AMAZON LINUX"
}
}
resource "aws_security_group" "default" {
name = lookup(var.awsprops, "secgroupname")
description = lookup(var.awsprops, "secgroupname")
// To Allow SSH Transport
ingress {
from_port = 22
protocol = "tcp"
to_port = 22
cidr_blocks = ["0.0.0.0/0"]
}
// To Allow Port 80 Transport
ingress {
from_port = 80
protocol = "tcp"
to_port = 80
cidr_blocks = ["0.0.0.0/0"]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
lifecycle {
create_before_destroy = true
}
}
