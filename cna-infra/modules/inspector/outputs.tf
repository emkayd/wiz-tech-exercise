output "inspector_status" {
  description = "Inspector enablement status"
  value       = aws_inspector2_enabler.all.id
}

output "enabled_resource_types" {
  description = "Resource types enabled for Inspector scanning"
  value       = aws_inspector2_enabler.all.resource_types
}
