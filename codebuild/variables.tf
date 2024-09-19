variable "access_key" {
        description = "Access key to AWS console"
}
variable "secret_key" {
        description = "Secret key to AWS console"
}

variable "codebuild_name" {
        default = "Terraform-build-project"
}
variable "bucket_name" {
        default = "terraforms353bucket"
}
variable "GitHub_URL" {
        default = "https://github.com/gamidirakesh/AWS-CFT" ############ github URL #######
}

# variable "stackname" {
#         default = "Terraformstack"
# }

variable "source_credential_auth_type" {
  type        = string
  default     = "PERSONAL_ACCESS_TOKEN"
  description = "The type of authentication used to connect to a GitHub, GitHub Enterprise, or Bitbucket repository."
}

variable "source_credential_server_type" {
  type        = string
  default     = "GITHUB"
  description = "The source provider used for this project."
}
variable "source_credential_token" {
  type        = string
  default     = "" ######## provide your github authentication token ###
  description = "For GitHub or GitHub Enterprise, this is the personal access token. For Bitbucket, this is the app password."
}
variable "subnet_id_1" {
        description = "The VPC subnet the instance(s) will be created in"
        default = "subnet-0d904582a0b6d31ba"
}
variable "subnet_id_2" {
        description = "The VPC subnet the instance(s) will be created in"
        default = "subnet-03f3ca608d8cebe6a"
}

variable "git_branch" {
        description = "The Security group Id"
        default = "main"
}

variable "security_group_id" {
        description = "The Security group Id"
        default = "sg-0ad30a664c1e052d4"
}

variable "buildspec_name" {
        default = "buildspec.yaml"
}