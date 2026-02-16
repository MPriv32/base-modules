
output "kms_key_arn" {
  value = module.networking.kms_key_arn
}

output "kms_key_id" {
  value = module.networking.kms_key_id
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "endpoint_security_group_id" {
  value = module.networking.endpoint_security_group_id
}
