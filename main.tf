####################################################
# VPC
####################################################

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet-gw]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  tags = {
    Name = "${var.environment}-${var.project_name}-vpc"
  }
}

# Public subnetss
resource "aws_subnet" "public_subnet" { 
  count = length(var.vpc_public_subnets)
  cidr_block        = var.vpc_public_subnets[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.vpc_azs[count.index % length(var.vpc_azs)]

  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
  }
}

# Private subnetss
resource "aws_subnet" "private_subnet" { 
  count = length(var.vpc_private_subnets)
  cidr_block        = var.vpc_private_subnets[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.vpc_azs[count.index % length(var.vpc_azs)]
  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
    Environment = var.environment
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-internet-gw"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.private_subnet[0].id
  depends_on = [aws_eip.nat_eip]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-public-rt"
    Environment = var.environment
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-private-rt"
    Environment = var.environment
  }
}


# Associate the newly created route tables to the subnets
resource "aws_route_table_association" "public-route-association" {
  count = length(aws_subnet.public_subnet)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}
resource "aws_route_table_association" "private-route-association" {
  count = length(aws_subnet.private_subnet)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}

/* # route table for public subnet - connecting to Internet gateway
resource "aws_default_route_table" "public" {
  default_route_table_id = module.vpc.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.igw_id
  }

resource "aws_route_table_association" "private" {
  count          = length(var.vpc_private_subnets)
  subnet_id      = module.vpc.private_subnets[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.vpc_private_subnets)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-private-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.vpc_private_subnets)
  subnet_id      = module.vpc.private_subnets[count.index]
  route_table_id = aws_route_table.private[count.index].id
}
*/

####################################################
# ALB
####################################################

# Create an AWS load balancerweb_server_lb
resource "aws_lb" "web_server_lb" {
  name               = "${var.environment}-${var.project_name}-${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets = aws_subnet.public_subnet.*.id

  #enable_deletion_protection = true  # Set to true if you want to enable deletion protection

  tags = {
    Name = "load-balancer"
    Environment = var.environment
  }
}


# Define a target group for the web server instances
resource "aws_lb_target_group" "web_servers_target_group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id     = aws_vpc.vpc.id
  #target_type = "instance"
  #load_balancing_algorithm_type = "round_robin"

  health_check {
    enabled              = true
    path                = var.health_check_path
    port                = 80
    protocol = "HTTP"
    unhealthy_threshold = 2
    healthy_threshold   = 2
    timeout             = 65
    interval            = 100
    matcher = "200"
    
  }
}


# Register web server instances with the target group
resource "aws_lb_target_group_attachment" "web_servers_attachment" {
  count           = length(aws_instance.web_servers.*.id)
  target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  #TODO: target_id       = aws_ecs_service.web_servers.id
  target_id       = aws_instance.web_servers[count.index].id
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
      values = ["/health"]
    }
  }
}


# Security group for the ALB - allowing http & https request from the internet
resource "aws_security_group" "alb_security_group" {
  name = "alb-security-group"
  description        = "Security group for the ALB"
  vpc_id             = aws_vpc.vpc.id

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
  name        = "ec2-security-group"
  vpc_id = aws_vpc.vpc.id

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
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index % length(var.vpc_private_subnets))
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  
  # Define your instance configuration here (e.g., user data for running a web server)
  user_data = <<-EOF
              #!/bin/bash
              echo "${count.index + 1}" > ~/instanceNumber.txt
              echo "<h1>Hello from web-server ${count.index + 1}</h1>" > /var/www/html/index.html
              echo "<h1>web-server-${count.index + 1}</h1>" > /var/www/health/index.html
              sudo apt update
              sudo apt install -y apache2
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
    "Name"        = "web-server-${count.index + 1}"
    "Environment" = "Test"
    "CreatedBy"   = "Terraform"
  }
  timeouts {
    create = "2m"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}