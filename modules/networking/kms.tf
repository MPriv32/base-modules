resource "aws_kms_key" "this" {
  deletion_window_in_days = 30

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Name      = "${var.name}-ecr-key"
  })
}