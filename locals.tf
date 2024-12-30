locals {
  project_ids = ["proj1", "proj2", "proj3"] # Example list of project_ids
  app_id      = "my-app"                   # Example app_id
  sdlc_name   = "dev"                      # Example SDLC environment
  lob         = ""                         # Example Line of Business (leave empty if undefined)

  # Determine namespace name based on the presence of lob
  vault_namespace = (
    local.lob != "" ? 
    "${local.lob}_${local.sdlc_name}_namespace" : 
    "gcp_${local.sdlc_name}_namespace"
  )

  # Map of GCP secret backends to create
  gcp_secret_backends = {
    for project_id in local.project_ids : "${local.vault_namespace}/gcp_${local.app_id}_${project_id}" => {
      project_id = project_id
      app_id     = local.app_id
    }
  }
}

# Create GCP secret backends in Vault
resource "vault_gcp_secret_backend" "gcp_backends" {
  for_each = local.gcp_secret_backends

  backend       = each.key
  project       = each.value.project_id
  credentials   = file("/path/to/gcp-service-account-key.json") # Replace with your actual GCP service account key file
  token_scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
}

# Configure roles for each GCP secret backend
resource "vault_gcp_secret_backend_role" "gcp_roles" {
  for_each = local.gcp_secret_backends

  backend       = each.key
  role          = "${each.value.project_id}-role"
  project       = each.value.project_id
  secret_type   = "access_token" # Can be "service_account_key" if needed
  bindings      = jsonencode({
    "roles/viewer" = ["serviceAccount:${local.app_id}@${each.value.project_id}.iam.gserviceaccount.com"]
  })
}