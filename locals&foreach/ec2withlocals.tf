# locals {
#   git_provider           = element(split("/", var.http_git_clone_url), 2)
#   git_protocal           = element(split(":", var.http_git_clone_url), 0)
#   git_owner              = element(split("/", var.http_git_clone_url), 3)
#   git_repo               = trimsuffix(element(split("/", var.http_git_clone_url), 4), ".git")
#   random_project_name    = "${local.git_repo}-${random_string.rand6.result}"
#   codebuild_project_name = (var.project_name != "" ? var.project_name : "${local.random_project_name}")
# }
locals {
  ami_id = "ami-0427090fd1714168b"
  Testing = "locals"
  instance_type = {
    instance1 = var.instance_type
    instance2 = var.instance_type2
  }
  name = "${var.name}-${var.combined_name}-${loclas.testing}-cicd"
}
resource "aws_instance" "terraform" {
  count         = 1
  ami           = local.ami_id
  instance_type = local.instance_type.instance1
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

resource "aws_s3_bucket" "my_bucket" {
  bucket = local.name
#   acl = "public-read-write"
  # versioning {enabled = true }
}
# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.my_bucket.id
#   acl    = "public-read-write"
# }