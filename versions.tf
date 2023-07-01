terraform {
  backend "s3" {
    bucket         = "rocky-wzva-terrafrom-state"
    key            = "learning-lambda-functions"
    encrypt        = true
    region         = "ap-southeast-2"
    role_arn       = "arn:aws:iam::658173543091:role/rocky-wzva-for-terraform-state-access"
    dynamodb_table = "rocky-wzva-terraform-state-lock"
  }
  required_version = ">= 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 1.0"
    }
  }
}
