resource "aws_codebuild_source_credential" "authorization" {
  auth_type   = var.source_credential_auth_type
  server_type = var.source_credential_server_type
  token       = var.source_credential_token ######## provide your github authentication token ###
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
  vpc_config {
    vpc_id = "vpc-0f4f64bbbe820043f"
    subnets = [
      var.subnet_id_1,
      var.subnet_id_2
    ]
    security_group_ids = [
      var.security_group_id
    #   aws_security_group.example2.id,
    ]
  }
  tags = {
    Environment = "Test"
  }

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


# resource "aws_codebuild_project" "project-with-cache" {
#   name           = "test-project-cache"
#   description    = "test_codebuild_project_cache"
#   build_timeout  = 5
#   queued_timeout = 5

#   service_role = aws_iam_role.example.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   cache {
#     type  = "LOCAL"
#     modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "SOME_KEY1"
#       value = "SOME_VALUE1"
#     }
#   }

#   source {
#     type            = "GITHUB"
#     location        = "https://github.com/mitchellh/packer.git"
#     git_clone_depth = 1
#   }

#   tags = {
#     Environment = "Test"
#   }
# }