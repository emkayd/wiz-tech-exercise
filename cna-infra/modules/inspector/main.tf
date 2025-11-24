provider "aws" {
  region = var.aws_region
}

resource "aws_inspector2_enabler" "all" {
  account_ids    = [var.account_id]
  resource_types = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE"]
}
