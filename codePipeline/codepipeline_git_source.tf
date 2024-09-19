# locals {
#   git_provider           = element(split("/", var.http_git_clone_url), 2)
#   git_protocal           = element(split(":", var.http_git_clone_url), 0)
#   git_owner              = element(split("/", var.http_git_clone_url), 3)
#   git_repo               = trimsuffix(element(split("/", var.http_git_clone_url), 4), ".git")
#   random_project_name    = "${local.git_repo}-${random_string.rand6.result}"
#   codebuild_project_name = (var.project_name != "" ? var.project_name : "${local.random_project_name}")
# }

resource "aws_codepipeline" "Terraform_code_pipeline" {
  name     = "terraform-pipeline"
  role_arn = "arn:aws:iam::905418457282:role/service-role/codepipeline-Role"
  artifact_store {
    location = aws_s3_bucket.my_bucket.id
    type     = "S3"
  }
  tags = {
    Environment = "Testing"
    Name        = "Rakesh"
  }
  stage {
    name = "Source_stage"
    action {
      name             = "Source_stage"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      input_artifacts  = []
      version          = "1"
      output_artifacts = ["internal"]
      configuration = {
        Repo    = "AWS-CFT"
        Branch    = var.git_branch
        OAuthToken = "" ############ provide your github authentication token ###
        Owner = "gamidirakesh"
        PollForSourceChanges = true
      }
    }
  }

 # Uncomment this section if you need the Build stage
#   stage {
#     name = "Build_stage"
#     action {
#       run_order        = 1
#       name             = "Terraform-Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       input_artifacts  = ["internal"]
#       output_artifacts = ["output"]
#       version          = "1"
#       configuration = {
#         ProjectName          = aws_codebuild_project.TerraformCodebuild.name
#         EnvironmentVariables = jsonencode([
#           {
#             name  = "PIPELINE_EXECUTION_ID"
#             value = "#{codepipeline.PipelineExecutionId}"
#             type  = "PLAINTEXT"
#           }
#         ])
#       }
#     }
#   }
  # stage {
  #   name = "Creation_Approval"
  #   action {
  #     run_order = 1
  #     name             = "Creation_Approval"
  #     category         = "Approval"
  #     owner            = "AWS"
  #     provider         = "Manual"
  #     version          = "1"
  #   }
  # }
  stage {
    name = "Deploy_stage"
    action {
      run_order        = 1
      name             = "Terraform"
      category          = "Deploy"
      owner            = "AWS"
      provider         = "CloudFormation"
      input_artifacts  = ["internal"]
      version          = "1"
      configuration = {
        ActionMode        = "CREATE_UPDATE"
        Capabilities = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND"
        RoleArn = "arn:aws:iam::905418457282:role/cftcloudformation"
        StackName = var.stackname
        TemplatePath = "internal::ec2cft.yml"
        
      }
    }
    action {
      run_order = 2
      name             = "Creation_Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
    }
  }
  stage {
    name = "Deletion_Approval"
    action {
      run_order = 1
      name             = "AWS-Admin-Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
    }
  }
  stage {
    name = "Deletion_stage"
    action {
      run_order        = 1
      name             = "Deletion"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CloudFormation"
      input_artifacts  = ["internal"]
      output_artifacts = []
      version          = "1"
      configuration = {
        ActionMode = "DELETE_ONLY"
        Capabilities = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND"
        RoleArn = "arn:aws:iam::905418457282:role/cftcloudformation"
        StackName = var.stackname
        TemplatePath = "internal::ec2cft.yml"
        
      }
    }
  }
}