terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
