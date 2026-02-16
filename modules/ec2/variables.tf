variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "private_subnet_id" {
  description = "ID of the private subnet to deploy EC2 into"
  type        = string
}

variable "key_name" {
  description = "Optional SSH key name (FedRAMP often disallows public SSH)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "attach_ecr_policy" {
  description = "Attach a policy to allow this instance to pull images from ECR"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Optional security groups to attach"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance and SG will be created"
  type        = string
}

variable "endpoint_security_group_id" {
  description = "ID of the endpoint security group to allow EC2 to connect to endpoints"
  type        = string
}