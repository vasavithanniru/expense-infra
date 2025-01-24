terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.66.0"
    }
  }

  backend "s3"{
    bucket = "vasavi-bucket"
    key = "expense-vpc-dev"
    region = "us-east-1" 
    dynamodb_table = "vasavi-table"
  }
}
provider "aws" {
  region = "us-east-1"
}
