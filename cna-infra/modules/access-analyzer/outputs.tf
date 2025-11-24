output "analyzer_arn" {
  description = "ARN of the IAM Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.arn
}

output "analyzer_name" {
  description = "Name of the IAM Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.analyzer_name
}
