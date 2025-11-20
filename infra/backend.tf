terraform {
  backend "s3" {
    bucket = "wiz-cloudlabs-tfstate-1234"  # <-- your actual bucket name
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}
