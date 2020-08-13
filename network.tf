# Create VPC to host infra
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "VPC of cluster ${var.cluster_name}"
  cidr = "10.0.0.0/16"

  azs = [var.aws_az]
  public_subnets = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  create_vpc         = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name = var.cluster_name
  }
}

#Create network interface with static IP in public subnet so we can reach the server GUI
#Also gives deterministic server address for clients to connect to
resource "aws_network_interface" "consul-server" {
  subnet_id   = module.vpc.public_subnets[0]
  private_ips = ["10.0.101.100"]
  security_groups = [aws_security_group.consul.id]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_network_interface" "test-server" {
  subnet_id   = module.vpc.public_subnets[0]
  private_ips = ["10.0.101.110"]
  security_groups = [aws_security_group.consul.id]

  tags = {
    Name = "primary_network_interface"
  }
}
