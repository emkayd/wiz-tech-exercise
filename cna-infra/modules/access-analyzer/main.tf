provider "aws" {
  region = var.aws_region
}

resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "wiz-access-analyzer"
  type          = "ACCOUNT"
}
