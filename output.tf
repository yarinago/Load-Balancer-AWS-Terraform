# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.web_server_lb.dns_name
}