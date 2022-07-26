output "db_instance_arn" {
  value       = aws_db_instance.this.arn
  description = "string ||| ARN of the SqlServer instance"
}

output "db_master_secret_name" {
  value       = aws_secretsmanager_secret.password.name
  description = "string ||| The name of the secret in AWS Secrets Manager containing the password"
}

output "db_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "string ||| The endpoint URL to access the SqlServer instance."
}

output "db_security_group_id" {
  value       = aws_security_group.this.id
  description = "string ||| The ID of the security group attached to the SqlServer instance."
}

output "db_user_security_group_id" {
  value       = aws_security_group.user.id
  description = "string ||| The ID of a security group that, when attached to a network device, allows access to the SqlServer instance."
}
