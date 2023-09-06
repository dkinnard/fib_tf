#------------------------------------------------------------------------------
# Utilizing ACM Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/route53/aws/latest
#------------------------------------------------------------------------------
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = "kinnard.me"

  records = [
    {
      name = "fib"
      type = "A"
      alias = {
        name    = module.alb.lb_dns_name
        zone_id = module.alb.lb_zone_id
      }
    }
  ]
}
