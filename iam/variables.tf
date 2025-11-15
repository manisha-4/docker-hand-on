variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_secrets_access" {
  description = "Enable access to Secrets Manager"
  type        = bool
  default     = true
}

variable "create_provisioner_role" {
  description = "Create a provisioner role and policy for CI/automation to provision ECR/ECS/CloudWatch/SQS/S3"
  type        = bool
  default     = true
}
