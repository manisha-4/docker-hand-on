provider "aws"{
  region="us-east-1"
  alias="us-east-1"
}

terraform {
  backend "s3"{
    key="docker-hands-on/terraform.tfstate"
    region="us-east-1"
  }
}