#------------------------------------------------------------------------------
# Utilizing ACM Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest
#------------------------------------------------------------------------------

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "fib.kinnard.me"
  zone_id     = "Z3U7I8GCV474CT"

  subject_alternative_names = [
    "*.fib.kinnard.me"
  ]

  wait_for_validation = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Customer    = "FIB"
  }
}

#------------------------------------------------------------------------------
# Utilizing ACM Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest
#------------------------------------------------------------------------------
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "fib-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  subnets         = data.terraform_remote_state.network.outputs.public_subnets
  security_groups = [data.terraform_remote_state.network.outputs.alb_sg]

  access_logs = {
    bucket = "fib-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "wpserv"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = data.terraform_remote_state.app.outputs.ec2_multiple.1.id
          port      = 80
        }
        my_other_target = {
          target_id = data.terraform_remote_state.app.outputs.ec2_multiple.2.id
          port      = 80
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Customer    = "FIB"
  }
}
