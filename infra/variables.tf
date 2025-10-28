variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "devsecops-project"
}

variable "app_repo_url" {
  description = "GitHub URL for PHP app"
  type        = string
}

variable "app_repo_branch" {
  description = "Branch to deploy"
  type        = string
  default     = "main"
}

# Feature flag to allow deploying without an ALB when the account does not permit it.
variable "use_alb" {
  description = "Whether to create the Application Load Balancer and route traffic through it"
  type        = bool
  default     = false
}