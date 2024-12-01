#Define the varible based on the requirememnts 
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

# VPC 
variable "project_name" {
  description = "Name of the project to be used as a prefix or suffix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string # getting from tfvars file
}

variable "public_subnets" {
  description = "Map of AZs to CIDR blocks for public subnets"
  type        = map(string) # getting from tfvars file
}

variable "private_subnets" {
  description = "Map of AZs to CIDR blocks for private subnets"
  type        = map(string) # getting from tfvars file
}

#EC2 Variables 

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "instance_name" {
  description = "The hostname to assign to the EC2 instance"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
}
