variable "aws_region" {
  description = "AWS region for WAF"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to associate with WAF"
  type        = string
}
