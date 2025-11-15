resource aws_iam_role ecs_task_execution_role {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}
resource aws_iam_policy_document ecs_task_execution_assume_role_policy {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource aws_iam_role_policy_attachment ecs_task_execution_role_policy_attachment {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource aws_iam_role ecs_task_role {
  name               = "ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}
resource aws_iam_policy_document ecs_task_assume_role_policy {
    statement {
    effect = "Allow"
    principals {
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    }
}
resource "aws_iam_role" "provisioner_role" {
    count              = var.create_provisioner_role ? 1 : 0
    name               = "${var.app_name}-${var.environment}-provisioner-role"
    assume_role_policy = data.aws_iam_policy_document.provisioner_assume_role_policy.json
}
resource "aws_iam_policy_document" "provisioner_assume_role_policy" {
    statement {
    effect = "Allow"
    principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    }
}