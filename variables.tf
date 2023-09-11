

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

################## EC2 ##################

variable "instance_tenancy" {
  description = "it defines the tenancy of VPC. Whether it's defsult or dedicated"
  type        = string
  default     = "default"
}

variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-087c17d1fe0178315"
}

variable "instance_type" {
  description = "Instance type to create an instance"
  type        = string
  default     = "t2.micro"
}

#variable "ssh_private_key" {
#  description = "pem file of Keypair we used to login to EC2 instances"
#  type        = string
#  default     = "./Keypair-01.pem"
#}