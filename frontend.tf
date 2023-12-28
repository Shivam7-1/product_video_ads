
resource "null_resource" "app_engine_app" {
  provisioner "local-exec" {
    command = "gcloud app create --region ${var.region} || true"
  }
}

resource "null_resource" "frontend_install_deps" {
  provisioner "local-exec" {
    working_dir = var.frontend_dir
    command     = "npm install --legacy-peer-deps"
  }
}

resource "null_resource" "watch_frontend_src" {
  triggers = {
    always = "${uuid()}"
  }

  provisioner "local-exec" {
    # command = "find -s ${var.frontend_dir}/src -type f -exec md5sum {} | md5sum > frontend-checksum"
    command = "find ${var.frontend_dir}/src -type f -print0 | xargs -0 sha1sum | sha1sum > frontend-checksum"
  }
}

resource "null_resource" "frontend_build" {
  triggers = {
    src_changed = "${sha1(file("frontend-checksum"))}"
  }
  provisioner "local-exec" {
    working_dir = var.frontend_dir
    command     = "npm run build --configuration=production"
  }

  depends_on = [
    null_resource.frontend_install_deps,
    null_resource.watch_frontend_src
  ]
}

resource "local_file" "dist_env_js" {
  # triggers = {
  #   env_js = "${sha1(file("${var.frontend_dir}/src/assets/js/env.js"))}"
  # }
  # provisioner "file" {
  content = templatefile("${var.frontend_dir}/src/assets/js/env.js", {
    FRONTEND_CLIENT_ID = google_iap_client.project_client.client_id
    FRONTEND_API_KEY   = google_iap_client.project_client.secret
  })
  # destination = "${var.frontend_dir}/dist/assets/js/env.js"
  # }
  filename   = "${var.frontend_dir}/dist/assets/js/env.js"
  depends_on = [null_resource.frontend_build]
}

resource "null_resource" "frontend_package" {
  provisioner "local-exec" {
    working_dir = var.frontend_dir
    command     = "zip -r app.zip dist"
  }

  depends_on = [local_file.dist_env_js]
}

resource "google_storage_bucket" "frontend_staging" {
  name                        = "pva_frontend_staging"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_object" "frontend_zip" {
  name   = "app.zip"
  source = "${var.frontend_dir}/app.zip"
  bucket = google_storage_bucket.frontend_staging.name
  depends_on = [
    null_resource.frontend_package
  ]
}

resource "google_app_engine_standard_app_version" "pva_v1" {
  depends_on = [google_storage_bucket_object.frontend_zip]
  version_id = "v1"
  service    = "default"
  runtime    = "nodejs20"
  entrypoint {
    shell = "npm run cloud-start"
  }

  handlers {
    url_regex = "/(login|products|bases|offer_types|generate)"
    static_files {
      path              = "dist/index.html"
      upload_path_regex = "dist/index.html"
    }
  }

  handlers {
    url_regex = "/(.+)"
    static_files {
      path              = "dist/\\1"
      upload_path_regex = "dist/.*"
    }
  }

  handlers {
    url_regex = "/"
    static_files {
      path              = "dist/index.html"
      upload_path_regex = "dist/index.html"
    }
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.frontend_staging.name}/${google_storage_bucket_object.frontend_zip.name}"
    }
  }
}
