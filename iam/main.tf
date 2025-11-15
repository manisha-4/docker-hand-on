# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

# Policy for a provisioner role: ECR login + create/manage ECS, CloudWatch, SQS, S3
resource "aws_iam_policy" "provisioner_policy" {
  count = var.create_provisioner_role ? 1 : 0

  name        = "${var.app_name}-provisioner-policy-${var.environment}"
  description = "Policy granting ECR login and permissions to create/manage ECS, CloudWatch, SQS and S3 resources"

  policy = jsonencode({
    Version = "2012-10-17"
      {
        Effect = "Allow"
        Action = [
          # ECR image pull/login
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # ECS management
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:CreateService",
          "ecs:UpdateService",
          "ecs:DeleteService",
          "ecs:RunTask",
          "ecs:Describe*",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # CloudWatch logs & metrics
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "cloudwatch:PutMetricData",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # SQS
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # S3
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # Allow passing of roles (needed when creating ECS services that use task roles)
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.app_name}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*-ecs-*"
        ]
      }
    ]
  })
}

# Provisioner role for CI / automation to assume and provision resources
resource "aws_iam_role" "provisioner_role" {
  count = var.create_provisioner_role ? 1 : 0

  name = "${var.app_name}-provisioner-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-provisioner-role"
    Environment = var.environment
  }
}

# Attach the policy to the provisioner role
resource "aws_iam_role_policy_attachment" "provisioner_policy_attach" {
  count      = var.create_provisioner_role ? 1 : 0
  role       = aws_iam_role.provisioner_role[0].name
  policy_arn = aws_iam_policy.provisioner_policy[0].arn
}

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-ecs-task-execution-role"
    Environment = var.environment
  }
}

# Attach the default ECS task execution role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for app permissions)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-ecs-task-role"
    Environment = var.environment
  }
}

# Additional policy for CloudWatch Logs
resource "aws_iam_role_policy" "ecs_task_execution_logs_policy" {
  name   = "${var.app_name}-ecs-task-logs-policy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.app_name}*"
      }
    ]
  })
}

# Policy for pulling images from ECR
resource "aws_iam_role_policy" "ecs_task_execution_ecr_policy" {
  name   = "${var.app_name}-ecs-task-ecr-policy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

# Optional: Policy for accessing Secrets Manager
resource "aws_iam_role_policy" "ecs_task_execution_secrets_policy" {
  count = var.enable_secrets_access ? 1 : 0
  name  = "${var.app_name}-ecs-task-secrets-policy"
  role  = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.app_name}/*"
        ]
      }
    ]
  })
}
