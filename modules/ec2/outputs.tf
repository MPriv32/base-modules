output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of EC2"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.this.id
}