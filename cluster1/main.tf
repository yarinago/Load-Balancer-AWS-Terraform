module "cluster" {
  source = "../modules/cluster"

  region         = "us-east-1"
  environment    = "dev"
  instance_count = 3
  aws_profile    = "beaconcure-terraform"

  vpc_cidr            = "10.0.0.0/16"
  vpc_azs             = ["us-east-1a", "us-east-1b"]
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  web_server_version = "alpine"
  instance_type      = "t2.micro"
  #ssh_private_key = "~/.ssh/aws/key_pair.pem"

}