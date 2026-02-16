variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type = string
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "enable_nat" {
  description = "Toggle NAT Gateway creation"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Toggle VPC flow logs"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

###############################################
# Backend S3 Creation Toggle
###############################################

variable "create_backend_s3" {
  description = "Whether to create the shared Terraform backend S3 bucket"
  type        = bool
  default     = false
}

###############################################
# Backend S3 Configuration
###############################################

variable "backend_bucket_name" {
  description = "Name of the Terraform backend S3 bucket"
  type        = string
  default     = null
}

variable "backend_force_destroy" {
  description = "Allow bucket to be destroyed even if not empty"
  type        = bool
  default     = false
}

variable "backend_object_lock_days" {
  description = "Default object lock retention in days"
  type        = number
  default     = 7
}

variable "backend_enable_kms" {
  description = "Whether to use KMS encryption instead of AES256"
  type        = bool
  default     = false
}

variable "backend_kms_key_arn" {
  description = "Existing KMS key ARN for S3 encryption (if not creating one)"
  type        = string
  default     = null
}

variable "create_ecr_endpoints" {
  description = "Whether to create ECR VPC endpoints (interface endpoints) for private EC2 access"
  type        = bool
  default     = false
}

variable "endpoint_tags" {
  description = "Tags for VPC endpoints"
  type        = map(string)
  default     = {}
}