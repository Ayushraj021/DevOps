provider "aws" {
region = "ap-south-1"
}

resource "aws_instance" "one" {
ami = "ami-0e0e417dfa2028266"
instance_type = "t2.micro"
}
