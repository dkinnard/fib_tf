provider "aws" {
  region = "us-east-1"
}

# Configure Terraform to use DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "fib-tfstate"
    key            = "fib/network"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
  }
}
