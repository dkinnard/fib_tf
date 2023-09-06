#------------------------------------------------------------------------------
# Bastion SG
#------------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name_prefix = "bastion-sg"
  description = "bastion security group"
  vpc_id      = module.vpc.vpc_id
}


resource "aws_security_group_rule" "bastion_public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_rdp_in" {
  type        = "ingress"
  description = "RDP from home"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["24.26.195.117/32"]

  security_group_id = aws_security_group.bastion.id
}

#------------------------------------------------------------------------------
# App SG
#------------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name_prefix = "app-sg"
  description = "web app security group"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group_rule" "app_public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id

  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id

  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_https_from_alb" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id

  security_group_id = aws_security_group.app.id
}

#------------------------------------------------------------------------------
# DB SG
#------------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name_prefix = "db-sg"
  description = "rds security group"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group_rule" "db_public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "db_psql_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id

  security_group_id = aws_security_group.db.id
}

#------------------------------------------------------------------------------
# ALB SG
#------------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name_prefix = "alb-sg"
  description = "alb security group"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group_rule" "alb_public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb.id
}

#------------------------------------------------------------------------------
# Canary SG
#------------------------------------------------------------------------------
resource "aws_security_group" "canary" {
  name_prefix = "canary-sg"
  description = "canary security group"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group_rule" "canary_public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.canary.id
}
