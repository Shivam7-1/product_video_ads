terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    gdrive = {
      source = "michael-richard-3r/gdrive"
      version = "0.4.1"
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

# data "external" "brand" {
#   program = ["bash", "gcloud alpha iap oauth-brands list --format=json"]
# }

# import {
#   to = google_iap_brand.project_brand
#   id = data.external.brand.result.name
# }

resource "google_iap_brand" "project_brand" {
  support_email     = var.support_email
  application_title = "PVA"
}

resource "google_iap_client" "project_client" {
  display_name = "PVA Web"
  brand        = google_iap_brand.project_brand.name
}

# data "external" "service_account" {
#   program = ["bash", "gcloud iam service-accounts list --format=json --filter=displayName:\"${var.service_account_name}\""]
# }


resource "google_service_account" "pva_account" {
  account_id = "pva-service-account"
  display_name = var.service_account_name
}
