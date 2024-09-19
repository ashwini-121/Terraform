###############  resources creation ######################
resource "aws_instance" "terraform-server" {
  count                  = 1
  # ami = lookup(var.terraform, "AMI")
  # instance_type = lookup(var.terraform, "itype")
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = var.ami_key_pair_name
  vpc_security_group_ids = [aws_security_group.security_group_id.id]
  #vpc_security_group_ids = ["sg-0ad30a664c1e052d4"]
  subnet_id = var.subnet_id
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
    Name     = "terraformec2"
    Provider = "aws"
  }
}

resource "aws_security_group" "security_group_id" {
  name = "TerraformSG"
  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  // To Allow Port 80 Transport
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.bucket_name}"
#   acl = "public-read-write"
  versioning {enabled = true }
}
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read-write"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.terraform-server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.terraform-server.public_ip
}
output "security_group_id" {
  description = "Public IP address of the EC2 instance"
  value       = aws_security_group.security_group_id.id
}


resource "aws_s3_bucket" "my_bucket" {
  # bucket = "${var.bucket_name}"
#   acl = "public-read-write"
#   versioning {enabled = true }
}
# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.my_bucket.id
#   acl    = "public-read-write"
# }
##### enabling bucket permission #########
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
############## Creating Kms Key ##############
# resource "aws_kms_key" "terraform_key" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 7
#   is_enabled = false
# }
# resource "aws_kms_alias" "terraform_key" {
#   name          = "alias/terraformkmskey"
#   target_key_id = aws_kms_key.terraform_key.key_id
# }
################### Bucket encryption ##################
# resource "aws_s3_bucket_server_side_encryption_configuration" "SSE" {
#   bucket = aws_s3_bucket.my_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.terraform_key.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }
################### Bucket policies ######################
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_bucket.id
 
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
#################### Lifecycle policy #################################
# resource "aws_s3_bucket_lifecycle_configuration" "bucket-lifecycleconfig" {
#   bucket = aws_s3_bucket.my_bucket.id
#   rule {
#     id = "GlacierRule"
#     expiration {
#       days = 3
#     }
#     filter {
#       and {
#         prefix = "test/"
#         tags = {
#           rule      = "log"
#           autoclean = "true"
#         }
#       }
#     }
#     status = "Enabled"
#     # transition {
#     #   days          = 1
#     #   storage_class = "GLACIER"
#     # }
#     transition {
#       days          = 2
#       storage_class = "GLACIER_IR"
#     }
#   }
#   rule {
#     id = "maltipartuploard"
#     # filter {
#     #   prefix = "tmp/"
#     # }
#     expiration {
#       days = 7
#     }
#     status = "Enabled"
#   }
# }
