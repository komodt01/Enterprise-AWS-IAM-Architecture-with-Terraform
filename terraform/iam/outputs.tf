output "security_architect_role_name" {
  description = "Name of the security architect IAM role"
  value       = aws_iam_role.security_architect.name
}

output "security_architect_role_arn" {
  description = "ARN of the security architect IAM role"
  value       = aws_iam_role.security_architect.arn
}

output "readonly_policy_arn" {
  description = "ARN of the read-only IAM visibility policy"
  value       = aws_iam_policy.security_architect.arn
}

output "department_abac_policy_arn" {
  description = "ARN of the department-based ABAC policy"
  value       = aws_iam_policy.department_abac.arn
}
