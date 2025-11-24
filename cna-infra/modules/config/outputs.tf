#If the service-linked role for Config doesn’t exist (sandbox restriction), this module may fail. Worst case, you can #comment out the recorder resources and just keep the bucket + note it in your narrative.

output "config_bucket_name" {
  value = aws_s3_bucket.config_logs.bucket
}
