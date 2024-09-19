variable "access_key" {
        description = "Access key to AWS console"
}
variable "secret_key" {
        description = "Secret key to AWS console"
}

variable "instance_type" {
        default = "t2.micro"
}

variable "subnet_id" {
        description = "The VPC subnet the instance(s) will be created in"
        default = "subnet-0d904582a0b6d31ba"
}

variable "ami_id" {
        description = "The Security group Id"
        default = "ami-0427090fd1714168b"
}

variable "security_group_id" {
        description = "The Security group Id"
        default = "sg-0ad30a664c1e052d4"
}

variable "ami_key_pair_name" {
        default = "test"
}