output "ecr_repository_url" {
  description = "ECR repository URL created by the module"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN created by the module"
  value       = module.ecr.repository_arn
}