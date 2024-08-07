resource "google_cloud_run_v2_service" "default" {

  depends_on = [
    google_service_account_iam_member.iam_member,
    google_service_account_iam_binding.act_as_iam,
  ]

  name     = var.service_name
  location = var.cloud_region
  project  = var.project_id

  template {
    containers {
      image = var.image_url

      ports {
        container_port = 80
      }

      resources {
        limits = {
          memory = "512Mi"
          cpu    = "1"
        }
        cpu_idle = true
        startup_cpu_boost = false
      }

      env {
        name  = "ASPNETCORE_URLS"
        value = join(",", var.aspnetcore_urls)
      }
      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.aspnetcore_environment
      }
      env {
        name  = "MONGODB_URL"
        value = var.mongodb_url
      }
      env {
        name  = "MONGODB_DATABASE"
        value = var.mongodb_database
      }
      env {
        name  = "QUERY_STRUCTURE_COLLECTION_NAME"
        value = var.query_structure_collection_name
      }
      env {
        name  = "QUERY_STRUCTURE_SEQUENCE_COLLECTION_NAME"
        value = var.query_structure_sequence_collection_name
      }
      env {
        name  = "CLIENT_COLLECTION_NAME"
        value = var.client_collection_name
      }
      env {
        name  = "CLIENT_SEQUENCE_COLLECTION_NAME"
        value = var.client_sequence_collection_name
      }
      env {
        name  = "OPENAI_API_BASE_URL"
        value = var.openai_api_base_url
      }
      env {
        name  = "OPENAI_API_RETRY_ATTEMPTS"
        value = var.openai_api_retry_attempts
      }
      env {
        name  = "OPENAI_API_RETRY_DELAY_IN_SECONDS"
        value = var.openai_api_retry_delay_in_seconds
      }
      env {
        name  = "TZ"
        value = var.tz
      }

    }

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    service_account = var.service_name
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_service_account" "default_service_account" {
  account_id   = var.service_name
  display_name = var.service_name
  project      = data.google_project.project.project_id
}

resource "google_service_account_iam_binding" "act_as_iam" {
  service_account_id = google_service_account.default_service_account.name
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.default_service_account.email}",
  ]
}

resource "google_service_account_iam_member" "iam_member" {
  service_account_id = google_service_account.default_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.default_service_account.email}"
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"

    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "noauth" {
  project  = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# gsutil mb -p duckhome-firebase -c STANDARD -l southamerica-east1 gs://duckhome-qsc-terraform-state
terraform {
  backend "gcs" {
    bucket = "duckhome-qsc-terraform-state"
    prefix = "terraform/state"
  }
}
