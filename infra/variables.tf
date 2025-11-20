variable "aws_region" {
  description = "AWS region for CloudLabs environment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster (used in subnet tags)"
  type        = string
  default     = "wiz-eks-cluster"
}

variable "mongo_ami_id" {
  description = "ami-0c33429de58b2edf4"
  type        = string
}

variable "mongo_instance_type" {
  description = "Instance type for MongoDB EC2"
  type        = string
  default     = "t3.small"
}

variable "mongo_key_name" {
  description = "wiz-interview-key1"
  type        = string
}

variable "mongo_backup_bucket_name" {
  description = "Name of the S3 bucket used for MongoDB backups"
  type        = string
}
