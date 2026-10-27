variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for PR Tracker host"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of existing AWS EC2 Key Pair to attach"
  type        = string
  default     = "pr-tracker-key"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID (leave empty to auto-detect latest Ubuntu AMI)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block permitted to SSH into EC2 (use your IP e.g. 203.0.113.50/32 in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "project_name" {
  description = "Project name tag"
  type        = string
  default     = "pr-tracker"
}

variable "environment" {
  description = "Environment tag (dev, staging, prod)"
  type        = string
  default     = "production"
}
