# ECS IAM Roles and Policies

This Terraform module creates the necessary IAM roles and policies required to execute ECS tasks in AWS.

## Overview

The module creates:

1. **ECS Task Execution Role** - Used by the ECS service to pull images and manage logs
   - Permissions to pull images from ECR
   - CloudWatch Logs permissions
   - Secrets Manager access (optional)

2. **ECS Task Role** - Used by the application running in the task
   - Can be extended with application-specific permissions

## Required Variables

- `app_name` (string) - Application name
- `aws_region` (string, optional) - AWS region (default: us-east-1)
- `environment` (string, optional) - Environment name (default: dev)
- `enable_secrets_access` (bool, optional) - Enable Secrets Manager access (default: true)

## Outputs

- `ecs_task_execution_role_arn` - ARN of the ECS task execution role
- `ecs_task_execution_role_name` - Name of the ECS task execution role
- `ecs_task_role_arn` - ARN of the ECS task role
- `ecs_task_role_name` - Name of the ECS task role

## Usage

```hcl
module "ecs_iam" {
  source = "./iam"

  app_name    = "my-app"
  environment = "dev"
  aws_region  = "us-east-1"
}

# Use in ECS task definition
resource "aws_ecs_task_definition" "example" {
  # ... other configuration ...
  execution_role_arn = module.ecs_iam.ecs_task_execution_role_arn
  task_role_arn      = module.ecs_iam.ecs_task_role_arn
}
```

## Included Permissions

### Task Execution Role
- **CloudWatch Logs**: Create log groups, streams, and write logs
- **ECR**: Get authorization tokens and pull images
- **Secrets Manager**: Get secret values and KMS decrypt (if enabled)

### Task Role
- Can be extended with application-specific permissions

## GitHub Actions Deployment

The `deploy-iam.yml` workflow:
- Runs on changes to `terraform/iam/**` files
- Performs terraform plan on PRs
- Applies on merge to main branch
- Supports manual deployment to dev, staging, or prod
- Uses AWS IAM role assumption via OIDC (no access keys required)

### Setup: Create an AWS Role for GitHub Actions

First, create an IAM role in AWS that GitHub Actions can assume:

```bash
# Set your GitHub repository details
GITHUB_OWNER="manisha-4"
GITHUB_REPO="docker-hand-on"

# Create the OIDC provider (one-time setup)
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"

# Create the role trust policy
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_OWNER}/${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF

# Create the IAM role
aws iam create-role \
  --role-name github-actions-terraform-role \
  --assume-role-policy-document file://trust-policy.json

# Attach policy to create/manage IAM roles and policies
cat > github-actions-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:GetRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:DeleteRole",
        "iam:CreatePolicy",
        "iam:GetPolicy",
        "iam:DeletePolicy",
        "iam:ListPolicies",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:GetRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListRoleTags"
      ],
      "Resource": [
        "arn:aws:iam::<AWS_ACCOUNT_ID>:role/*-ecs-*",
        "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/*-ecs-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*:<AWS_ACCOUNT_ID>:log-group:/ecs/*"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name github-actions-terraform-role \
  --policy-name github-actions-terraform-policy \
  --policy-document file://github-actions-policy.json

# Get the role ARN
ROLE_ARN=$(aws iam get-role --role-name github-actions-terraform-role --query 'Role.Arn' --output text)
echo "Role ARN: $ROLE_ARN"
```

### Configure GitHub Secrets

Add the role ARN as a GitHub secret:

1. Go to your GitHub repository Settings → Secrets and variables → Actions
2. Create a new secret named `AWS_ROLE_TO_ASSUME`
3. Set its value to the role ARN from above

Optionally, add AWS region as a variable:

1. Go to Settings → Variables → Actions
2. Create a new variable named `AWS_REGION`
3. Set it to your desired region (default: us-east-1)

### Required GitHub Secrets

```
AWS_ROLE_TO_ASSUME       - ARN of the IAM role for GitHub Actions
APP_NAME                 - Application name (as a secret)
```

### Optional GitHub Variables

```
AWS_REGION              - AWS region (default: us-east-1)
```

## Development

Format Terraform files:
```bash
terraform fmt -recursive
```

Validate configuration:
```bash
terraform validate
```

Plan changes:
```bash
terraform plan -var="app_name=my-app" -var="environment=dev"
```

Apply changes:
```bash
terraform apply -var="app_name=my-app" -var="environment=dev"
```
