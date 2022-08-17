terraform {
  required_version = "~> 1.1.7"

  backend "gcs" {
    bucket = "mahamed-coen-state"
    prefix = "k8s-ar-testing"
  }

  required_providers {
    google = {
      version = "~> 4.16.0"
    }
    google-beta = {
      version = "~> 4.16.0"
    }
  }
}

provider "google" {
  project = "coen-mahamed-ali"
}

provider "google-beta" {
  project = "coen-mahamed-ali"
}
