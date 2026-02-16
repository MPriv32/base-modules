variable "name" {
  description = "Name prefix used for all ECS resources (cluster, service, ALB, task definition, etc.)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ECS service and ALB will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs used for the Application Load Balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS Fargate tasks will run."
  type        = list(string)
}

variable "container_image" {
  description = "Full container image URI (e.g., ECR repository URL with tag) to deploy to ECS."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container and used by the target group."
  type        = number
  default     = 8000
}

variable "region" {
  description = "AWS region where resources are deployed. Used for logging configuration."
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all ECS-related resources."
  type        = map(string)
  default     = {}
}

variable "endpoint_security_group_id" {
  description = "ID of the endpoint security group to allow ECS to connect to endpoints"
  type        = string
}