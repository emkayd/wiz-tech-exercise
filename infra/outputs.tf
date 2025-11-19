output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnets for ALB and public-facing resources (and NAT)."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]
}

output "private_subnet_ids" {
  description = "Private subnets for EKS worker nodes."
  value = [
    aws_subnet.private_mongo_a.id,
    aws_subnet.private_b.id,
  ]
}
