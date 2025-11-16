/*
	ECS cluster + Fargate task definition with CloudWatch logging

	Variables expected (provide via tfvars or CI):
	- app_name
	- environment
	- aws_region
	- container_image
	- container_port
	- cpu, memory
	- subnet_ids (list)
	- security_group_ids (list)
	- task_execution_role_arn (IAM role with ecs task execution permissions)
	- task_role_arn (optional task role for application permissions)
	- desired_count
	- assign_public_ip

*/
app_name = "to-do-app"
environment = "prod"
aws_region = "us-east-1"
container_image = "to-do-app-image"
container_port = "80"
cpu="2048"
memory = "4096"
ecs_task_execution_role_arn = "arn:aws:iam::529875232668:role/ecsTaskExecutionRole"
ecs_task_role_arn= "arn:aws:iam::529875232668:role/ecsTaskRole"