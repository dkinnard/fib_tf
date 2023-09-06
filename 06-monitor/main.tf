#------------------------------------------------------------------------------
# Utilizing ACM Module from Terraform registry 
# https://registry.terraform.io/modules/clouddrove/cloudwatch-synthetics/aws/latest
#------------------------------------------------------------------------------
module "canaries" {
  source              = "clouddrove/cloudwatch-synthetics/aws"
  version             = "1.3.1"
  name                = "Web_Application_Alive"
  environment         = "fib-dev"
  label_order         = ["name", "environment"]
  schedule_expression = "rate(5 minutes)"
  s3_artifact_bucket  = "fib-canary"         # must pre-exist
  alarm_email         = "dkinnard@gmail.com" # you need to confirm this email address
  endpoints           = { "fib-alb" = { url = "https://fib.kinnard.me" } }
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnets
  security_group_ids  = [data.terraform_remote_state.network.outputs.canary_sg]
  depends_on          = [module.s3_bucket]
}
