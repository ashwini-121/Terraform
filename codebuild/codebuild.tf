# locals {
#   git_provider           = element(split("/", var.http_git_clone_url), 2)
#   git_protocal           = element(split(":", var.http_git_clone_url), 0)
#   git_owner              = element(split("/", var.http_git_clone_url), 3)
#   git_repo               = trimsuffix(element(split("/", var.http_git_clone_url), 4), ".git")
#   random_project_name    = "${local.git_repo}-${random_string.rand6.result}"
#   codebuild_project_name = (var.project_name != "" ? var.project_name : "${local.random_project_name}")
# }
resource "aws_codebuild_source_credential" "authorization" {
  auth_type   = var.source_credential_auth_type
  server_type = var.source_credential_server_type
  token       = var.source_credential_token  ######### Provide your github authentication token ###
}
resource "aws_codebuild_project" "TerraformCodebuild" {
  name          = "${var.codebuild_name}"
  description   = "Creating ec2 instance using code build"
  build_timeout = 30
  ################ Attach your codebuild service role ###########################
  service_role  = "arn:aws:iam::905418457282:role/service-role/Codebuild-service-role"
  source_version = "${var.git_branch}"
  source {
    type            = "GITHUB"
    location        = var.GitHub_URL
    buildspec = var.buildspec_name
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/java:openjdk-8"
    type                        = "LINUX_CONTAINER"
    # image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "BRANCH_NAME"
      value = "main"
    }
    environment_variable {
      name  = "PIPELINE_NAME"
      value = "terraform-pipeline"
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.my_bucket.id}/log"
    }
  }
  tags = {
    Environment = "Test"
  }
  # vpc_config {
  #   vpc_id = "vpc-0f4f64bbbe820043f"
  #   subnets = [
  #     var.subnet_id_1,
  #     var.subnet_id_2
  #   ]
  #   security_group_ids = [
  #     var.security_group_id
  #   #   aws_security_group.example2.id,
  #   ]
  # }

#   vpc_config {
#     vpc_id = aws_vpc.example.id

#     subnets = [
#       aws_subnet.example1.id,
#       aws_subnet.example2.id,
#     ]

#     security_group_ids = [
#       aws_security_group.example1.id,
#       aws_security_group.example2.id,
#     ]
#   }
}
##########  Webhook enabling ###############
resource "aws_codebuild_webhook" "TerraformCodebuild" {
  project_name = aws_codebuild_project.TerraformCodebuild.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    # filter {
    #   type    = "BASE_REF"
    #   pattern = "master"
    # }
    filter {
      type    = "HEAD_REF"
      pattern = "main"
    }
  }
}
