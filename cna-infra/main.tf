terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ------------------------
# CloudTrail (control plane + data events)
# ------------------------
module "cloudtrail" {
  source = "./modules/cloudtrail"

  aws_region          = var.aws_region
  account_id          = var.account_id
  trail_name          = "wiz-cna-trail"
  log_bucket_name     = var.cloudtrail_bucket_name
  include_s3_data     = true
  include_lambda_data = false  # Disabled due to ARN format issues
}

# ------------------------
# AWS Config (detect config drift)
# ------------------------
# Commented out to avoid conflict with existing "wizexercise-recorder"
# Only one Config recorder allowed per region
# module "config" {
#   source = "./modules/config"
#
#   aws_region            = var.aws_region
#   account_id            = var.account_id
#   recorder_name         = "wiz-cna-recorder"
#   delivery_channel_name = "wiz-cna-delivery"
#   config_bucket_name    = var.config_bucket_name
# }

# ------------------------
# Security Hub
# ------------------------
module "securityhub" {
  source = "./modules/securityhub"

  aws_region = var.aws_region
}

# ------------------------
# GuardDuty
# ------------------------
module "guardduty" {
  source = "./modules/guardduty"

  aws_region = var.aws_region
}

# ------------------------
# VPC Flow Logs
# ------------------------
module "vpc_flow_logs" {
  source = "./modules/vpc_flow_logs"

  aws_region     = var.aws_region
  vpc_id         = var.eks_vpc_id # reuse VPC from main infra
  log_group_name = "/wiz/cna/vpc-flow-logs"
}

# ------------------------
# Inspector (vulnerability scanning)
# ------------------------
module "inspector" {
  source = "./modules/inspector"

  aws_region = var.aws_region
  account_id = var.account_id
}

# ------------------------
# IAM Access Analyzer
# ------------------------
module "access_analyzer" {
  source = "./modules/access-analyzer"

  aws_region = var.aws_region
}

# ------------------------
# WAF (Web Application Firewall)
# ------------------------
module "waf" {
  source = "./modules/waf"

  aws_region = var.aws_region
  alb_arn    = var.alb_arn
}
