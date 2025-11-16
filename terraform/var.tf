variable "app_name" {
	type = string
}

variable "environment" {
	type    = string
	default = "dev"
}

variable "aws_region" {
	type    = string
	default = "us-east-1"
}



variable "container_port" {
	type    = number
	default = 80
}

variable "cpu" {
	type    = number
	default = 256
}

variable "memory" {
	type    = number
	default = 512
}

variable "desired_count" {
	type    = number
	default = 1
}



variable "task_execution_role_arn" {
	type    = string
	default = ""
}

variable "task_role_arn" {
	type    = string
	default = ""
}

variable "mongo_db_name" {
	type    = string
	default = "todo_db"
	description = "MongoDB database name"
}