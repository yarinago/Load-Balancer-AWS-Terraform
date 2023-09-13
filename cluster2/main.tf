/*module "cluster2" {
  source = "../modules/cluster"
  region = "us-west-2"
  environment = "test"
  project_name = "beaconcure"
  instance_count = 2
  shared_credentials_files = "~/.aws/credentials"
  aws_profile = "default" #TODO: CHANGE TO beaconcure-terraform

  vpc_cidr = "10.0.0.0/16"
  vpc_azs = ["us-west-2a", "us-west-2b"]
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  vpc_enable_nat_gateway = true

  ec2_health_check_path = "/"
  alb_health_check_path = "/health"
  alb_name = "load-balancer"

  web_server_version = "alpine"
  ec2_instance_name = "terraform-lab"
  ami_id = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  #ssh_private_key = "~/.ssh/aws/key_pair.pem"
}*/