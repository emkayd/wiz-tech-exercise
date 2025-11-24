output "cloudtrail_trail_arn" {
  value = aws_cloudtrail.this.arn
}

output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs.bucket
}
