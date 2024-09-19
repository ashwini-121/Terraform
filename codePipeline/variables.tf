variable "access_key" {
        description = "Access key to AWS console"
}
variable "secret_key" {
        description = "Secret key to AWS console"
}

variable "codebuild_name" {
        default = ""
}
variable "bucket_name" {
        default = "terraforms35303bucket"
}
variable "GitHub_URL" {
        default = "https://github.com/gamidirakesh/AWS-CFT.git"
}

variable "stackname" {
        default = "Terraformstack"
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