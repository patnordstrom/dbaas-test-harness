terraform {
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.7"
}