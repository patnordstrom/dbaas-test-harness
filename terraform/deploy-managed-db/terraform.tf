terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.34"
    }
  }

  required_version = ">= 1.7"
}