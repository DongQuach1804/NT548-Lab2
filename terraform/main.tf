# Tạo IAM role cho EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "lab02-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "lab02-ec2-role"
  }
}

# Tạo instance profile từ IAM role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "lab02-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach policy cho EC2 role (SSM để quản lý instance)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role. ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Tạo CloudWatch Log Group cho VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/lab02-vpc-flow-logs"
  retention_in_days = 7

  tags = {
    Name = "lab02-vpc-flow-logs"
  }
}

# Tạo IAM role cho VPC Flow Logs
resource "aws_iam_role" "vpc_flow_log_role" {
  name = "lab02-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts: AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "lab02-vpc-flow-log-role"
  }
}

# Policy cho VPC Flow Logs để ghi vào CloudWatch
resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "lab02-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs: PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id          = module.vpc. vpc_id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_log_role. arn
  log_destination = aws_cloudwatch_log_group. vpc_flow_log.arn

  tags = {
    Name = "lab02-vpc-flow-log"
  }
}

# Restrict default security group
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  # Không có ingress/egress rules = block tất cả traffic

  tags = {
    Name = "lab02-default-sg-restricted"
  }
}

module "subnet" {
  source              = "./modules/subnet"
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = var. public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source           = "./modules/nat"
  public_subnet_id = module.subnet.public_subnet_id
}

module "route_table" {
  source            = "./modules/route-table"
  vpc_id            = module.vpc.vpc_id
  igw_id            = module. igw.igw_id
  nat_gateway_id    = module.nat.nat_gateway_id
  public_subnet_id  = module.subnet.public_subnet_id
  private_subnet_id = module.subnet.private_subnet_id
}

module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_ip
}

module "ec2" {
  source               = "./modules/ec2"
  ami_id               = var. ami_id
  instance_type        = var.instance_type
  key_name             = var. key_name
  public_subnet_id     = module.subnet. public_subnet_id
  private_subnet_id    = module. subnet.private_subnet_id
  public_sg_id         = module.security_group.public_sg_id
  private_sg_id        = module.security_group.private_sg_id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}