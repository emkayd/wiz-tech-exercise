resource "aws_s3_bucket" "mongo_backups" {
  bucket = var.mongo_backup_bucket_name

  tags = {
    Name        = "wiz-mongo-backups"
    Environment = "cloudlabs"
    Purpose     = "MongoDB daily backups"
  }
}

# Optional but nice: versioning on backups
resource "aws_s3_bucket_versioning" "mongo_backups" {
  bucket = aws_s3_bucket.mongo_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Optional: default encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "mongo_backups" {
  bucket = aws_s3_bucket.mongo_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
