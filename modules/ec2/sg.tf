###########################################
# Security Group for EC2
###########################################

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Private EC2 SG"
  vpc_id      = var.vpc_id

  # Allow SSH only from allowed bastion (optional)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [] # restrict or leave empty
  }

  # Allow all outbound for ECR / NAT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { ManagedBy = "Terraform" })
}

resource "aws_security_group_rule" "allow_ec2_to_endpoint" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = var.endpoint_security_group_id
  source_security_group_id = aws_security_group.this.id
}
