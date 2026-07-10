terraform {
  backend "s3" {
    key     = "dev/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}