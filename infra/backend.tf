terraform {
  backend "s3" {
    bucket = "wiz-cloudlabs-tfstate-92837" # <-- your bucket name
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}
