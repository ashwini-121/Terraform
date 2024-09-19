resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.bucket_name}"
#   acl = "public-read-write"
  # versioning {enabled = true }
}
# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.my_bucket.id
#   acl    = "public-read-write"
# }
##### enabling bucket versioning #########
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
# ################## Bucket encryption ##################
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
 
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
################### Lifecycle policy #################################
resource "aws_s3_bucket_lifecycle_configuration" "bucket-lifecycleconfig" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    id = "GlacierRule"
    expiration {
      days = 3
    }
    filter {
      and {
        prefix = "test/"
        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }
    status = "Enabled"
    # transition {
    #   days          = 1
    #   storage_class = "GLACIER"
    # }
    transition {
      days          = 2
      storage_class = "GLACIER_IR"
    }
  }
  rule {
    id = "maltipartuploard"
    # filter {
    #   prefix = "tmp/"
    # }
    expiration {
      days = 7
    }
    status = "Enabled"
  }
}