


resource "aws_ecr_repository" "main" {
    name = "${var.app_name}-${var.environment}-ecr-repository"
}

resource "aws_ecs_cluster" "main" {
    name = "${var.app_name}-${var.environment}-ecs-cluster"
}
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
    name              = "/ecs/${var.app_name}-${var.environment}"
    retention_in_days = 14
}

resource "aws_ecs_task_definition" "app" {
	family                   = "${var.app_name}-${var.environment}"
	requires_compatibilities = ["FARGATE"]
	network_mode             = "awsvpc"
	cpu                      = var.cpu
	memory                   = var.memory
	execution_role_arn       = var.task_execution_role_arn
	task_role_arn            = var.task_role_arn

	container_definitions = jsonencode([
		{
			name  = var.app_name
			image = "${aws_ecr_repository.main.repository_url}:latest"
			environment = [
				{
					name  = "ENVIRONMENT"
					value = var.environment
				},
				{
					name  = "AWS_REGION"
					value = var.aws_region
				},
				{
					name  = "MONGO_URI"
					value = "mongodb://localhost:27017/${var.mongo_db_name}"
				}
			]
			portMappings = [
				{
					containerPort = var.container_port
					protocol      = "tcp"
				}
			]
			essential = true
			logConfiguration = {
				logDriver = "awslogs"
				options = {
					awslogs-group         = aws_cloudwatch_log_group.ecs_task_logs.name
					awslogs-region        = var.aws_region
					awslogs-stream-prefix = var.app_name
				}
			}
			dependsOn = [
				{
					containerName = "mongo"
					condition     = "HEALTHY"
				}
			]
		},
		{
			name  = "mongo"
			image = "mongo:6"
			portMappings = [
				{
					containerPort = 27017
					protocol      = "tcp"
				}
			]
			essential = false
			logConfiguration = {
				logDriver = "awslogs"
				options = {
					awslogs-group         = aws_cloudwatch_log_group.ecs_task_logs.name
					awslogs-region        = var.aws_region
					awslogs-stream-prefix = "mongo"
				}
			}
			healthCheck = {
				command     = ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
				interval    = 10
				timeout     = 5
				retries     = 3
				startPeriod = 30
			}
		}
	])
}

# resource "aws_ecs_service" "app" {
# 	name            = "${var.app_name}-${var.environment}-service"
# 	cluster         = aws_ecs_cluster.main.id
# 	desired_count   = var.desired_count
# 	launch_type     = "FARGATE"
# 	task_definition = aws_ecs_task_definition.app.arn

# 	network_configuration {
# 		subnets          = var.subnet_ids
# 		security_groups  = var.security_group_ids
# 		assign_public_ip = var.assign_public_ip
# 	}

# 	lifecycle {
# 		ignore_changes = [task_definition]
# 	}

# 	depends_on = [aws_ecs_task_definition.app]
# }

# Outputs

output "ecs_cluster_arn" {
	value       = aws_ecs_cluster.main.arn
	description = "ARN of the ECS cluster"
}

output "ecs_cluster_name" {
	value       = aws_ecs_cluster.main.name
	description = "Name of the ECS cluster"
}

output "ecs_task_definition_arn" {
	value       = aws_ecs_task_definition.app.arn
	description = "ARN of the ECS task definition"
}

output "ecs_service_name" {
	value       = aws_ecs_service.app.name
	description = "Name of the ECS service"
}

output "ecr_repository_url" {
	value       = aws_ecr_repository.main.repository_url
	description = "ECR repository URL for pushing images"
}
