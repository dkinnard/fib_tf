provider "aws" {
  region = "us-east-1"
}

# Configure Terraform to use DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "fib-tfstate"
    key            = "fib/acm"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "fib-tfstate"
    key    = "fib/network"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "app" {
  backend = "s3"
  config = {
    bucket = "fib-tfstate"
    key    = "fib/app"
    region = "us-east-1"
  }
}
