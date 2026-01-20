resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_11:VPC Flow Logs cannot be enabled due to IAM restrictions in AWS Lab
  #checkov:skip=CKV2_AWS_12:Default security group will be restricted in main.tf
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab02-vpc"
  }
}