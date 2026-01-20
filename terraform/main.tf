module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

# Restrict default security group (không cần IAM)
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

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
  source            = "./modules/ec2"
  ami_id            = var. ami_id
  instance_type     = var.instance_type
  key_name          = var. key_name
  public_subnet_id  = module.subnet. public_subnet_id
  private_subnet_id = module.subnet.private_subnet_id
  public_sg_id      = module.security_group.public_sg_id
  private_sg_id     = module.security_group.private_sg_id
}