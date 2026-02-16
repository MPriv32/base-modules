output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs keyed by AZ"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs keyed by AZ"
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "nat_enabled" {
  value = var.enable_nat
}

output "backend_bucket_name" {
  value       = var.create_backend_s3 ? aws_s3_bucket.tf_state[0].id : null
  description = "Terraform backend bucket name"
}

output "kms_key_arn" {
  value = aws_kms_key.this.arn
}

output "kms_key_id" {
  value = aws_kms_key.this.id
}

output "ecr_api_endpoint_ids" {
  value = { for k, ep in aws_vpc_endpoint.ecr_api : k => ep.id }
}

output "ecr_dkr_endpoint_ids" {
  value = { for k, ep in aws_vpc_endpoint.ecr_dkr : k => ep.id }
}

output "ecr_api_endpoint_dns" {
  value = { for k, ep in aws_vpc_endpoint.ecr_api : k => ep.dns_entry[*].dns_name }
}

output "ecr_dkr_endpoint_dns" {
  value = { for k, ep in aws_vpc_endpoint.ecr_dkr : k => ep.dns_entry[*].dns_name }
}

output "endpoint_security_group_id" {
  value = aws_security_group.endpoint_sg.id
}
