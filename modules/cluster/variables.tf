variable "region" {
  description = "The AWS region to create resources in."
  type = string
}

variable "environment" {
  description = "Name of environment"
  type        = string
}

variable "project_name" {
  description = "Name of entire project"
  type        = string
}

variable "instance_count" {
  description = "Number of web server instances to create"
  type        = number
}

variable "shared_credentials_files" {
  description = "The path to the aws profile's credentials files"
  type        = string
}

variable "aws_profile" {
  description = "The name of the AWS profile"
  type        = string
}


################## VPC ##################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
}

################## ALB ##################

variable "alb_health_check_path" {
  description = "Health check path for the alb - dns/path"
  type = string
}


variable "alb_name" {
  description = "The Application Load Balancer name"
  type = string
}

################## EC2 ##################

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type = string
}

variable "ami_id" {
  description = "ami id"
  type        = string
}

variable "instance_type" {
  description = "Instance type to create an instance"
  type        = string
}

variable "ec2_health_check_path" {
  description = "Health check path for the default target group"
  type = string
}

variable "web_server_version" {
  description = "Version of the web server"
  type        = string
}


/*variable "ssh_private_key" {
  description = "pem file of Keypair we used to login to EC2 instances"
  type        = string
  default     = "~/.ssh/aws/key_pair.pem"
}*/