variable "account" {
  description = "The AWS Account Number (10 digit) to create resources in."
  type = string
}

variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "environment" {
  description = "Name of environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of entire project"
  type        = string
  default     = "beaconcure"
}

variable "instance_count" {
  description = "Number of web server instances to create"
  type        = number
  default     = 3  # You can change this default value
}

################## VPC ##################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "it defines the tenancy of VPC. Whether it's default or dedicated"
  type        = string
  default     = "default"
}

################## ALB ##################

variable "health_check_path" {
  description = "Health check path for the default target group"
  type = string
  default     = "/health"
}

variable "alb_name" {
  description = "The Application Load Balancer name"
  type = string
  default     = "load-balancer"
}

################## EC2 ##################

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  default     = "terraform-lab"
}

variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  description = "Instance type to create an instance"
  type        = string
  default     = "t2.micro"
}

/*variable "ssh_private_key" {
  description = "pem file of Keypair we used to login to EC2 instances"
  type        = string
  default     = "~/.ssh/aws/key_pair.pem"
}*/