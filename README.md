# FIB IaaC

Written in Terraform, this repo contains everything needed to deploy the FIB development environment in AWS.  [Community modules for Terraform](https://registry.terraform.io/namespaces/terraform-aws-modules) are heavily utilized for this project.

## Requirements

* Workstation or deployment server with Terraform 1.0 or greater.
* Registered domain name with corresponding hosted zone in Route53.

## AWS resources provisioned

* VPC with public, application, and database subnets.
* Bastion host (t3a.medium) running Windows Server 2019.
* Two RHEL8 EC2 instances (t3a.micro) running the FIB web app.
* Postgres 14 server (db.t3.micro).
* Application load balancer.
* CloudWatch canary directed to the load balancer to monitor application health.

## Deployment

- Update `main.tf` and `r53.tf` in the `05-alb` directory with your domain name and Hosted Zone ID.  You can obtain the HostedZoneId from the AWS console by clicking on the Hosted Zone, then Hosted Zone Details.  Alternatively you can grab the ID by running `aws route53 list-hosted-zones
- Rename the S3 buckets that will be created in `05-alb/log-bucket.tf` and `06-monitor/artifact-bucket.tf` since S3 bucket names must be unique across AWS.
- Run `terraform init` then `terraform apply` in each directory, following the numeric order.


