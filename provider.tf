terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.205.0"
    }
  }
}

provider "alicloud" {
  # Configuration options
  profile = var.profile 
  region  = "ap-southeast-5"
}



