#------------------------------------------------------------------------------
# Utilizing EC2-Instance Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
#------------------------------------------------------------------------------

locals {
  user_data = <<-EOT
    #!/bin/bash
    INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
    AV_ZONE=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
    AWS_REGION=$${AV_ZONE::-1}
    NAME_TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query 'Tags[*].Value' --output text --region=$AWS_REGION)
    hostnamectl set-hostname $NAME_TAG_VALUE
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  EOT

  multiple_instances = {

    1 = {
      ami               = data.aws_ami.rhel8.id
      instance_type     = "t3a.micro"
      availability_zone = "us-east-1a"
      hostname          = "wpserver1"
      subnet_id         = data.terraform_remote_state.network.outputs.private_subnets[0]
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          volume_size = 20
        }
      ]
    }
    2 = {
      ami               = data.aws_ami.rhel8.id
      instance_type     = "t3a.micro"
      availability_zone = "us-east-1b"
      hostname          = "wpserver2"
      subnet_id         = data.terraform_remote_state.network.outputs.private_subnets[1]
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp2"
          volume_size = 20
        }
      ]
    }
  }
}

module "ec2_multiple" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = local.multiple_instances

  name                        = "wpserver${each.key}"
  instance_type               = each.value.instance_type
  availability_zone           = each.value.availability_zone
  subnet_id                   = each.value.subnet_id
  key_name                    = "FIB"
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.app_sg]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    DescribeTags = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  }

  root_block_device = lookup(each.value, "root_block_device", [])

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Customer    = "FIB"
  }
}



#------------------------------------------------------------------------------
# Query for latest rhel 8.6 AMI
#------------------------------------------------------------------------------
data "aws_ami" "rhel8" {
  owners = ["233035487920"]

  filter {
    name   = "name"
    values = ["RHEL_8.6-x86_64-SQL_2022_Standard-2022*"]
  }

  most_recent = true

}
