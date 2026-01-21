terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Artifact Registry API
resource "google_project_service" "artifact_registry" {
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "agent-backend-repo"
  description   = "Docker repository for Agent Backend"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifact_registry]
}

# Service Account for the Backend
resource "google_service_account" "backend_sa" {
  account_id   = "agent-backend-sa"
  display_name = "Agent Backend Service Account"
}

# Cloud Run Service for Backend
resource "google_cloud_run_service" "backend" {
  name     = "agent-backend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.backend_sa.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/agent-backend-repo/agent-backend:latest"
        ports {
          container_port = 8080
        }
        env {
          name  = "ENV_TYPE"
          value = "production"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.cloudrun]
}

# Allow unauthenticated invocations (optional, for demo)
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
