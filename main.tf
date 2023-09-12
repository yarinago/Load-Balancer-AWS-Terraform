####################################################
# VPC
####################################################

resource "aws_eip" "nat_eip" {
  count = length(module.vpc.private_subnets)


  tags = {
    Name = "nat eip"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.environment}-${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  create_igw = true
  reuse_nat_ips = true # Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = aws_eip.nat_eip[*].id # IPs specified here as input to the module

  tags = {
    Name = "${var.environment}-${var.project_name}-vpc"
    Environment = var.environment
  }
}

/*
# Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id     = module.vpc.vpc_id
  #subnet_id  = module.vpc.public_subnets[count.index]
}

# route table for public subnet - connecting to Internet gateway
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

# associate the route table with private subnet
resource "aws_route_table_association" "internet_gateway_route_associate" {
  count = length(module.vpc.private_subnets)
  subnet_id      = module.vpc.public_subnets[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(module.vpc.private_subnets)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = module.vpc.private_subnets[count.index].id
  depends_on = [aws_internet_gateway.internet_gw]

  tags = {
    Name = "NAT for private subnet"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  count = length(module.vpc.private_subnets)
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
}

# associate the route table with private subnet
resource "aws_route_table_association" "nat_gateway_route_associate" {
  count = length(module.vpc.private_subnets)
  subnet_id      = module.vpc.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}*/


####################################################
# ALB
####################################################

# Create an AWS load balancerweb_server_lb
resource "aws_lb" "web_server_lb" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = module.vpc.public_subnets
  # [for subnet in module.vpc.public_subnets : subnet.id]

  enable_deletion_protection = false  # Set to true if you want to enable deletion protection

  tags = {
    Name = "load-balancer"
    Environment = var.environment
  }
}


# Define a target group for the web server instances
resource "aws_lb_target_group" "web_servers_target_group" {
  name     = "load-balancer-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id     = module.vpc.vpc_id
  #target_type = "instance"
  load_balancing_algorithm_type = "round_robin"


  health_check {
    enabled              = true
    path                = "/health"
    port                = 80
    protocol            = "HTTP"
    unhealthy_threshold = 2
    healthy_threshold   = 2
    timeout             = 65
    interval            = 100
    matcher = "200"
  }
}


# Register web server instances with the target group
resource "aws_lb_target_group_attachment" "web_servers_attachment" {
  count = var.instance_count
  target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  target_id       = aws_instance.web_servers[count.index].id
  port = 80
}


# Define a listener for HTTP traffic on port 80
resource "aws_lb_listener" "web_servers_listener" {
  load_balancer_arn = aws_lb.web_server_lb.arn
  port              = 80
  protocol          = "HTTP"

  # Forward incoming requests to the target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  }
}

# Define a listener for HTTP traffic on port 80
resource "aws_lb_listener_rule" "lb_health_check" {
  listener_arn = aws_lb_listener.web_servers_listener.arn

  action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = aws_lb.web_server_lb.name
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = [var.health_check_path]
    }
  }
}


# Attach the target group to the ALB listener
/*resource "aws_lb_listener_rule" "web_servers_routing_rule" {
  listener_arn = aws_lb_listener.web_servers_listener.arn

  action {
    type             = "fixed-response"
    fixed_response {
      content_type    = "text/plain"
      status_code     = "200"
      message_body    = "Hello from the web server ${aws_ecs_service.web_servers.name}"
      
    }
  }

  condition {
    path_pattern {
      values = ["/web-server/*"]
    }
  }

  priority = 1
}*/



# Security group for the ALB - allowing http & https request from the internet
resource "aws_security_group" "alb_security_group" {
  name_prefix        = "alb-sg-"
  description        = "Security group for the ALB"
  vpc_id             = module.vpc.vpc_id

  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the EC2 - allowing http request from the ALB only
resource "aws_security_group" "ec2_security_group" {
  name_prefix        = "ec2-sg-"
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "Allow http request from Load Balancer"
    protocol        = "tcp"
    from_port       = 80 # range of
    to_port         = 80 # port numbers
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow inbound traffic from ALB to ECS
/*resource "aws_security_group_rule" "alb_to_ecs" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.alb_security_group.id
}*/


####################################################
# EC2
####################################################

/* The private key generated by tls_private_key is stored unencrypted in your terraform state file which is unsafe
   We only use this method for a locally testing
   The proper way is to create the key outside terraform and call the pub file */  
resource "tls_private_key" "web_server_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "web-servers-key-pair" {
  key_name   = "${var.project_name}-key-pair"
  public_key = trimspace(tls_private_key.web_server_key.public_key_openssh)
}

# Create web server instances
resource "aws_instance" "web_servers" {
  count         = var.instance_count
  ami           = var.ami_id  # Specify the AMI ID for your Ubuntu image
  instance_type = var.instance_type           # Choose an appropriate instance type
  key_name      = aws_key_pair.web-servers-key-pair.key_name
  #iam_instance_profile = data.aws_iam_role.iam_role.name
  subnet_id = module.vpc.private_subnets[count.index % length(module.vpc.private_subnets)]
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  
  # Define your instance configuration here (e.g., user data for running a web server)
  user_data = <<-EOF
              #!/bin/bash
              echo "${count.index + 1}" > ~/instanceNumber.txt
              echo "<h1>Hello from web-server ${count.index + 1}</h1>" > /var/www/html/index.html
              echo "<h1>web-server-${count.index + 1}</h1>" > /var/www/health/index.html
              systemctl start apache2
              
              #sudo apt update
              #sudo apt install -y docker.io

              #sudo docker run -d -p 80:80 \
              #    --name apache-web-server \
              #    -v /var/www/html:/usr/local/apache2/htdocs \
              #    -v /var/www/health:/usr/local/apache2/health \
              #    httpd:alpine
              EOF
  
  tags = {
    "Name"        = "${var.environment}-web-server-${count.index + 1}"
    "Environment" = var.environment
  }
  timeouts {
    create = "10m"
  }
}