variable "aws_region" {
  description = "AWS region to deploy CNA controls"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "682033491815"
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "config_bucket_name" {
  description = "S3 bucket name for AWS Config logs"
  type        = string
}

variable "eks_vpc_id" {
  description = "VPC ID where EKS/Mongo live (from main infra outputs)"
  type        = string
}
