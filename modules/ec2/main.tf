###########################################
# EC2 Instance
###########################################

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.this.name
  vpc_security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.this.id]
  key_name               = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    encrypted             = true
  }

  tags = merge(var.tags, { Name = var.name })
}
