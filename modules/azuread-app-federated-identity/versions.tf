terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.44.0"
    }
  }
  required_version = ">= 1.3.8"
}
