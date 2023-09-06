#------------------------------------------------------------------------------
# Utilizing VPC Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.1.1?tab=inputs
#------------------------------------------------------------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "fib-vpc"
  cidr = "10.1.0.0/16"

  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets   = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnets  = ["10.1.2.0/24", "10.1.3.0/24"]
  database_subnets = ["10.1.4.0/24", "10.1.5.0/24"]

  public_subnet_names   = ["Public Subnet 1", "Public Subnet 2"]
  private_subnet_names  = ["WP Subnet 1", "Private Subnet 2"]
  database_subnet_names = ["DB Subnet 1", "DB Subnet 2"]

  enable_nat_gateway           = true
  enable_vpn_gateway           = false
  create_database_subnet_group = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Customer    = "FIB"
  }
}
