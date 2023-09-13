output "shared_credentials_files" {
  value = var.shared_credentials_files
  sensitive = true

}

output "aws_profile" {
  value = var.aws_profile
  sensitive = false
}

output "alb_dns_name" {
  value = aws_lb.web_server_lb.dns_name
  sensitive = false
}

output "public_subnet" {
  value = aws_subnet.public_subnet
  sensitive = true
}

output "region" {
  value = var.region
  sensitive = false
}

output "availability_zone" {
  value = var.vpc_azs
  sensitive = false
}

output "environment" {
  value = var.environment
  sensitive = false
}