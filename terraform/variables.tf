variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI via SSM"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  type = string
  description = "EC2 Key Pair name"
}

variable "my_ip" {
  type = string
  description = "Your IP address for SSH access"
}
