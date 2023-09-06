#------------------------------------------------------------------------------
# Utilizing EC2-Instance Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#------------------------------------------------------------------------------

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                         = "fib-alb-logs"
  acl                            = "log-delivery-write"
  force_destroy                  = true
  control_object_ownership       = true
  object_ownership               = "ObjectWriter"
  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  versioning = {
    enabled = true
  }
}
