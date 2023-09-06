#------------------------------------------------------------------------------
# Utilizing RDS Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
#------------------------------------------------------------------------------

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds1"

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t3.micro"
  allocated_storage    = 5

  db_name  = "rds1"
  username = "fibdba"
  port     = "5432"

  multi_az               = true
  db_subnet_group_name   = data.terraform_remote_state.network.outputs.database_subnet_group_name
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.db_sg]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Customer    = "FIB"
    Terraform   = "True"
    Environment = "dev"
  }

  # Database Deletion Protection
  deletion_protection = true
}
