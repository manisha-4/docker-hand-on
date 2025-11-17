provider "aws"{
  region="us-east-1"
  alias="us-east-1"
}

terraform {
  backend "s3"{
    key="iam/terraform.tfstate"
    region="us-east-1"
  }
}