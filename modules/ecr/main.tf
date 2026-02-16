###############################################
# ECR Repository
# FedRAMP best practices:
# - Encryption at rest (SSE-KMS)
# - Immutable tags
# - Private repo only
# - Image scanning enabled
###############################################

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.enable_immutable_tags ? "IMMUTABLE" : "MUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Name      = var.name
  })
}

###############################################
# Lifecycle Policy (Optional, untagged image cleanup)
###############################################

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images"
        selection    = {
          tagStatus = "untagged"
          countType = "sinceImagePushed"
          countUnit = "days"
          countNumber = var.lifecycle_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
