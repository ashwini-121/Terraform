provider "aws" {
  region = "us-east-1" # Change this to your preferred region
  access_key = "Provide your access key"
  secret_key = "Provide your Secret key"
}

# Define the EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Change this to the AMI ID for your desired OS
  instance_type = "t2.micro" # You can change this to another instance type if needed
  key_name = "demo" # provide your keypair name
  vpc_security_group_ids = "sg-12345" #Your security group id
  tags = {
    Name = "MyEC2Instance"
  }
}
