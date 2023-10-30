resource "google_cloud_run_service" "default" {

  depends_on = [
    google_service_account_iam_member.iam_member,
    google_service_account_iam_binding.act_as_iam,
  ]

  name     = var.service_name
  location = var.cloud_region
  project  = var.project_id

  template {
    spec {
      service_account_name = var.service_name

      containers {
        image = var.image_url

        ports {
          container_port = 80
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
          value = var.QUERY_STRUCTURE_COLLECTION_NAME
        }
        env {
          name  = "QUERY_STRUCTURE_SEQUENCE_COLLECTION_NAME"
          value = var.QUERY_STRUCTURE_SEQUENCE_COLLECTION_NAME
        }
        env {
          name = "CLIENT_COLLECTION_NAME"
          value = var.CLIENT_COLLECTION_NAME
        }
        env {
          name = "CLIENT_SEQUENCE_COLLECTION_NAME"
          value = var.CLIENT_SEQUENCE_COLLECTION_NAME
        }
        env {
          name  = "TZ"
          value = var.tz
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "5"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
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

resource "google_cloud_run_service_iam_policy" "noauth" {
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_secret_manager_secret" "mongodb_url" {
  project   = var.project_id
  secret_id = "mongodb_url"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "mongodb_database" {
  project   = var.project_id
  secret_id = "mongodb_database"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "QUERY_STRUCTURE_COLLECTION_NAME" {
  project   = var.project_id
  secret_id = "QUERY_STRUCTURE_COLLECTION_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "QUERY_STRUCTURE_SEQUENCE_COLLECTION_NAME" {
  project   = var.project_id
  secret_id = "QUERY_STRUCTURE_SEQUENCE_COLLECTION_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "CLIENT_COLLECTION_NAME" {
  project   = var.project_id
  secret_id = "CLIENT_COLLECTION_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "CLIENT_SEQUENCE_COLLECTION_NAME" {
  project = var.project_id
  secret_id = "CLIENT_SEQUENCE_COLLECTION_NAME"
  replication {
    auto {}
  }
}
