variable "awsprops" {
type = map(string)
default = {
region = "us-east-1"
vpc = "vpc-064d02e610a8d66e0"#replace with you values for all
ami = "ami-03c7d01cf4dedc891"
itype = "t2.micro"
subnet = "subnet-018d7211b74a54935"
publicip = true
keyname = "myseckey"
secgroupname = "IAC-Sec-Group"
}
}
#This is other way of calling variables using the main2.tf