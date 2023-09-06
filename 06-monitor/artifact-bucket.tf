#------------------------------------------------------------------------------
# Utilizing EC2-Instance Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#------------------------------------------------------------------------------

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "fib-canary"
  #acl    = "private"
  force_destroy = true
  versioning = {
    enabled = true
  }
}
