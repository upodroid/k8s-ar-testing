// Registries
resource "google_artifact_registry_repository" "belgium" {
  location      = "europe-west1"
  repository_id = "images"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "london" {
  location      = "europe-west2"
  repository_id = "images"
  format        = "DOCKER"
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/artifactregistry.reader"
    members = [
      "allUsers",
    ]
  }
   binding {
    role = "roles/artifactregistry.repoAdmin"
    members = [
      "serviceAccount:${google_service_account.image_promoter.email}",
    ]
  }
}

resource "google_artifact_registry_repository_iam_policy" "belgium" {
  project = google_artifact_registry_repository.belgium.project
  location = google_artifact_registry_repository.belgium.location
  repository = google_artifact_registry_repository.belgium.name
  policy_data = data.google_iam_policy.admin.policy_data
}

resource "google_artifact_registry_repository_iam_policy" "london" {
  project = google_artifact_registry_repository.london.project
  location = google_artifact_registry_repository.london.location
  repository = google_artifact_registry_repository.london.name
  policy_data = data.google_iam_policy.admin.policy_data
}

// Service Accounts
resource "google_service_account" "image_promoter" {
  account_id   = "k8s-infra-gcr-promoter"
  display_name = "Service Account"
}

resource "google_service_account" "krel_trust" {
  account_id   = "krel-trust"
  display_name = "Service Account"
}

resource "google_service_account_iam_member" "id_token" {
  service_account_id = google_service_account.krel_trust.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.image_promoter.email}"
}

resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.image_promoter.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:coen-mahamed-ali.svc.id.goog[k8s/image-promoter]"
}

# resource "google_compute_instance" "default" {
#   name         = "ar-test"
#   machine_type = "n2d-standard-2"
#   zone         = "europe-west2-a"

#   boot_disk {
#     initialize_params {
#       image = "ubuntu/ubuntu-2204-lts"
#     }
#   }

#   network_interface {
#     network = "default"

#     access_config {
#     }
#   }

#   service_account {
#     email  = google_service_account.image_promoter.email
#     scopes = ["cloud-platform"]
#   }
# }
