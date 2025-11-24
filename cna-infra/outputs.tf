# cna-infra/outputs.tf

# CloudTrail
output "cloudtrail_bucket_name" {
  description = "S3 bucket name where CloudTrail logs are delivered"
  value       = module.cloudtrail.cloudtrail_bucket_name
}

output "cloudtrail_trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail.cloudtrail_trail_arn
}

# AWS Config
# Commented out because Config module is disabled (conflict with existing recorder)
# output "config_bucket_name" {
#   description = "S3 bucket name used by AWS Config"
#   value       = module.config.config_bucket_name
# }

# Security Hub
output "securityhub_enabled" {
  description = "Whether Security Hub is enabled"
  value       = module.securityhub.securityhub_enabled
}

# GuardDuty
output "guardduty_detector_id" {
  description = "Detector ID for GuardDuty"
  value       = module.guardduty.guardduty_detector_id
}

# VPC Flow Logs
output "vpc_flow_logs_log_group" {
  description = "CloudWatch Log Group used for VPC Flow Logs"
  value       = module.vpc_flow_logs.vpc_flow_logs_log_group
}

# Inspector
output "inspector_status" {
  description = "Inspector enablement status"
  value       = module.inspector.inspector_status
}

output "inspector_enabled_resource_types" {
  description = "Resource types enabled for Inspector scanning"
  value       = module.inspector.enabled_resource_types
}

# IAM Access Analyzer
output "access_analyzer_arn" {
  description = "ARN of the IAM Access Analyzer"
  value       = module.access_analyzer.analyzer_arn
}

output "access_analyzer_name" {
  description = "Name of the IAM Access Analyzer"
  value       = module.access_analyzer.analyzer_name
}
