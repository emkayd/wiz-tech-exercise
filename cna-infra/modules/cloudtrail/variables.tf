variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "trail_name" {
  type = string
}

variable "log_bucket_name" {
  type = string
}

variable "include_s3_data" {
  type    = bool
  default = true
}

variable "include_lambda_data" {
  type    = bool
  default = true
}
