data "aws_ssm_parameter" "amazon_linux" {
  name = var.ami_id
}

resource "aws_instance" "public" {
  #checkov:skip=CKV2_AWS_41: IAM role cannot be created due to AWS Lab restrictions
  ami                    = data.aws_ssm_parameter. amazon_linux.value
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var. key_name
  ebs_optimized          = true
  monitoring             = true
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "lab2-public-ec2"
  }
}

resource "aws_instance" "private" {
  #checkov: skip=CKV2_AWS_41:IAM role cannot be created due to AWS Lab restrictions
  ami                    = data.aws_ssm_parameter.amazon_linux.value
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.private_sg_id]
  ebs_optimized          = true
  monitoring             = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "lab02-private-ec2"
  }
}