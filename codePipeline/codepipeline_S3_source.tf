locals {
  codepipeline_name = "script"
  random_project_name    = "${local.codepipeline_name}-${var.codebuild_name}-cicd"
  codebuild_pipeline_name = (var.codebuild_name != "" ? var.codebuild_name : "${local.random_project_name}")
}

resource "aws_codepipeline" "Terraform_code_pipeline" {
  name     = local.codebuild_pipeline_name
  ################ Attach your codepipeline service role ###########################
  role_arn = "arn:aws:iam::905418457282:role/service-role/codepipeline-Role"

  artifact_store {
    location = "terraform5303codepipeline" ############### provide your s3 bucket name ##########
    type     = "S3"
  }

  tags = {
    Environment = "Testing"
    Name        = "Rakesh"
  }
########### Source stages as S3 ###################
  stage {
    name = "Source_stage"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["internal"]
      run_order        = 1
      configuration = {
        S3Bucket    = "terraforms35303bucket"
        S3ObjectKey = "internal.zip"
      }
    }
  }

  # Uncomment this section if you need the Build stage
  # stage {
  #   name = "Build_stage"
  #   action {
  #     run_order        = 1
  #     name             = "Terraform-Build"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     input_artifacts  = ["internal"]
  #     output_artifacts = ["output"]
  #     version          = "1"
  #     configuration = {
  #       ProjectName          = aws_codebuild_project.TerraformCodebuild.name
  #       EnvironmentVariables = jsonencode([
  #         {
  #           name  = "PIPELINE_EXECUTION_ID"
  #           value = "#{codepipeline.PipelineExecutionId}"
  #           type  = "PLAINTEXT"
  #         }
  #       ])
  #     }
  #   }
  # }
  
  ################# Deploy stage creates and execute's changeset ##########
  stage {
    name = "Deploy_stage"
    action {
      name            = "CreateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["internal"]
      version         = "1"
      run_order       = 1
      configuration = {
        ActionMode   = "CHANGE_SET_REPLACE"
        Capabilities = "CAPABILITY_IAM,CAPABILITY_AUTO_EXPAND"
        StackName    = var.stackname
        ChangeSetName = "terraformset"
        TemplatePath = "internal::ec2cft.yml"
        #### Provide your account's Cloudformation service role for resources creation ####
        RoleArn      = "arn:aws:iam::905418457282:role/cftcloudformation" 
      }
    }
    action {
      run_order = 2
      name             = "Review-Changeset"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
    }
    action {
      name            = "ExecuteChangeset"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["internal"]
      version         = "1"
      run_order       = 3
      configuration = {
        ActionMode   = "CHANGE_SET_EXECUTE"
        Capabilities = "CAPABILITY_IAM,CAPABILITY_AUTO_EXPAND"
        ChangeSetName = "terraformset"
        StackName    = var.stackname
        #### Provide your account's Cloudformation service role for resources creation ####
        RoleArn      = "arn:aws:iam::905418457282:role/cftcloudformation"
      }
    }

    action {
      run_order = 4
      name             = "Deploy_stage_signoff"
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
      version          = "1"
      configuration = {
        ActionMode   = "DELETE_ONLY"
        Capabilities = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND"
        #### Provide your account's Cloudformation service role for resources creation ####
        RoleArn      = "arn:aws:iam::905418457282:role/cftcloudformation"
        StackName    = var.stackname
        TemplatePath = "internal::ec2cft.yml"
      }
    }
  }
}
