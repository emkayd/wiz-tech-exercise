output "vpc_flow_logs_log_group" {
  value = aws_cloudwatch_log_group.vpc_flow_logs.name
}
