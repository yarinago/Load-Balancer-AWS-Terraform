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
  default     = "beaconcure"
}

variable "instance_count" {
  description = "Number of web server instances to create"
  type        = number
}

variable "shared_credentials_files" {
  description = "The path to the aws profile's credentials files"
  type        = string
  default     = "~/.aws/credentials"
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
  default = true
}

################## ALB ##################

variable "alb_health_check_path" {
  description = "Health check path for the alb - dns/path"
  type = string
  default = "/health"
}


variable "alb_name" {
  description = "The Application Load Balancer name"
  type = string
  default = "load-balancer"
}

################## EC2 ##################

variable "ami_name_filter" {
  description = "The ami filter vale for the name"
  type        = string
  default = "ubuntu*server*22.04*hvm*ssd*"
}

variable "ami_virtualization-type_filter" {
  description = "The ami filter vale for the virtualization-type"
  type        = string
  default = "hvm"
}

variable "ami_root-device-type_filter" {
  description = "The ami filter vale for the root-device-type"
  type        = string
  default = "ebs"
}

variable "ami_owners_filter" {
  description = "The ami filter vale for the owners"
  type        = string
  default = "099720109477" # Canonical
}

variable "instance_type" {
  description = "Instance type to create an instance"
  type        = string
}

variable "ec2_health_check_path" {
  description = "Health check path for the default target group"
  type = string
  default = "/"
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