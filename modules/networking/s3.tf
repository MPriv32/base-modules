###############################################
# Only create backend bucket if explicitly enabled
###############################################

resource "aws_s3_bucket" "tf_state" {
  count = var.create_backend_s3 ? 1 : 0

  bucket        = var.backend_bucket_name
  force_destroy = var.backend_force_destroy

  # Object lock must be enabled at creation
  object_lock_enabled = true

  tags = merge(var.tags, {
    Name    = var.backend_bucket_name
    Purpose = "terraform-backend"
  })
}

###############################################
# Versioning (required for object lock)
###############################################

resource "aws_s3_bucket_versioning" "tf_state" {
  count  = var.create_backend_s3 ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

###############################################
# Object Lock Configuration
###############################################

resource "aws_s3_bucket_object_lock_configuration" "tf_state" {
  count  = var.create_backend_s3 ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.backend_object_lock_days
    }
  }
}

###############################################
# Encryption Configuration
###############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  count  = var.create_backend_s3 ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  rule {
    apply_server_side_encryption_by_default {

      # If KMS enabled use KMS, else AES256
      sse_algorithm     = var.backend_enable_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.backend_enable_kms ? var.backend_kms_key_arn : null
    }
  }
}

###############################################
# Block All Public Access
###############################################

resource "aws_s3_bucket_public_access_block" "tf_state" {
  count  = var.create_backend_s3 ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###############################################
# Enforce TLS Only Access
###############################################

resource "aws_s3_bucket_policy" "tf_state_tls" {
  count  = var.create_backend_s3 ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.tf_state[0].arn,
          "${aws_s3_bucket.tf_state[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
