terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
  zone   = var.zone
}

resource "google_project_service" "project_service" {
  service = "iap.googleapis.com"
}

resource "google_iap_brand" "project_brand" {
  support_email     = var.support_email
  application_title = "PVA"
}

resource "google_iap_client" "project_client" {
  display_name = "PVA Web"
  brand        = google_iap_brand.project_brand.name
}


