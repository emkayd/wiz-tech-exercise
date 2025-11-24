output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb.id
}

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb.arn
}

output "web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb.name
}

output "web_acl_capacity" {
  description = "Web ACL capacity units (WCU) used"
  value       = aws_wafv2_web_acl.alb.capacity
}
