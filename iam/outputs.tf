output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task_role.name
}

output "provisioner_role_arn" {
  description = "ARN of the provisioner role (for CI/automation)"
  value       = length(aws_iam_role.provisioner_role) > 0 ? aws_iam_role.provisioner_role[0].arn : ""
}

output "provisioner_role_name" {
  description = "Name of the provisioner role"
  value       = length(aws_iam_role.provisioner_role) > 0 ? aws_iam_role.provisioner_role[0].name : ""
}

output "provisioner_policy_arn" {
  description = "ARN of the provisioner policy"
  value       = length(aws_iam_policy.provisioner_policy) > 0 ? aws_iam_policy.provisioner_policy[0].arn : ""
}
