variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "tags" {
  description = "Common tags for the ECR repository"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for encryption at rest. If not set, AWS managed key will be used."
  type        = string
  default     = null
}

variable "enable_immutable_tags" {
  description = "If true, images cannot be overwritten (immutable)"
  type        = bool
  default     = true
}

variable "lifecycle_days" {
  description = "Number of days to keep untagged images (optional cleanup)"
  type        = number
  default     = 30
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}