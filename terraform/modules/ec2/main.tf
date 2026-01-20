data "aws_ssm_parameter" "amazon_linux" {
  name = var.ami_id
}

resource "aws_instance" "public" {
  ami                    = data.aws_ssm_parameter.amazon_linux.value
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var.key_name
  ebs_optimized          = true
  monitoring             = true
  iam_instance_profile   = var.iam_instance_profile

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
  ami                    = data.aws_ssm_parameter.amazon_linux.value
  instance_type          = var.instance_type
  subnet_id              = var. private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.private_sg_id]
  ebs_optimized          = true
  monitoring             = true
  iam_instance_profile   = var. iam_instance_profile

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