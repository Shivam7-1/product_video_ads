#!/bin/bash

# Copyright 2023 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## 
export TF_VAR_project_id=$(gcloud config get-value project)
touch frontend-checksum
gcloud services enable compute.googleapis.com container.googleapis.com drive.googleapis.com
terraform init
terraform import google_storage_bucket.frontend_staging pva_frontend_staging
terraform import google_iap_brand.project_brand $(gcloud alpha iap oauth-brands list | grep name: | sed "s/name: //") || true
terraform import google_service_account.pva_account $(gcloud iam service-accounts list | grep pva-service-account | sed "s/EMAIL: //") || true
terraform apply