#------------------------------------------------------------------------------
# Utilizing EC2-Instance Module from Terraform registry 
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
#------------------------------------------------------------------------------
module "ec2_complete" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "bastion1"

  ami                         = data.aws_ami.win2019.id
  instance_type               = "t3a.medium"
  key_name                    = "FIB"
  monitoring                  = true
  vpc_security_group_ids      = [data.terraform_remote_state.network.outputs.bastion_sg]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnets[0]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    EC2ReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 50
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Customer    = "FIB"
  }
}



#------------------------------------------------------------------------------
# Query for latest Win 2019 server AMI
#------------------------------------------------------------------------------
data "aws_ami" "win2019" {
  owners = ["801119661308"] # Amazon

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  most_recent = true

}

#------------------------------------------------------------------------------
# Set Hostname via userdata
#------------------------------------------------------------------------------
locals {
  user_data = <<-EOF
          <powershell>
          Invoke-WebRequest "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"
          Start-Process msiexec.exe -Wait -ArgumentList '/I AWSCLIV2.msi /quiet'
          $instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id
          $tagName = & "C:\Program Files\Amazon\AWSCLIV2\aws" ec2 describe-tags --filters "Name=resource-id,Values=$instanceId" "Name=key,Values=Name" --query "Tags[0].Value" --output text
          $currentName = $env:COMPUTERNAME
          if ($currentName -ne $tagName) {
              Rename-Computer -NewName $tagName -Force
              Restart-Computer -Force
          }
          </powershell>
          EOF
}
