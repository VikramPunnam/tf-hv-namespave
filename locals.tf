



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




locals {
  project_ids      = ["proj1", "proj2", "proj3"]       # Example list of GCP project IDs
  subscription_ids = ["sub1", "sub2", "sub3"]         # Example list of Azure subscription IDs
  app_id           = "my-app"                        # Example app_id
  sdlc_name        = "dev"                           # Example SDLC environment
  lob              = ""                              # Example Line of Business (leave empty if undefined)
  cloud_provider   = "gcp"                           # Example cloud provider ("gcp" or "azure")

  # Determine namespace name based on the cloud provider and presence of lob
  vault_namespace = (
    local.cloud_provider == "gcp" ?
    (local.lob != "" ? "${local.lob}_${local.sdlc_name}_namespace" : "azure_${local.sdlc_name}_namespace") :
    (local.lob != "" ? "${local.lob}_${local.sdlc_name}_namespace" : "gcp_${local.sdlc_name}_namespace")
  )

  # Determine identifiers based on the cloud provider
  identifiers = (
    local.cloud_provider == "gcp" ? local.project_ids : local.subscription_ids
  )

  # Map of secret backends to create
  secret_backends = {
    for id in local.identifiers : "${local.vault_namespace}/${local.cloud_provider}_${local.app_id}_${id}" => {
      identifier = id
      app_id     = local.app_id
    }
  }
}

# Create Azure or GCP secret backends in Vault
resource "vault_gcp_secret_backend" "gcp_backends" {
  for_each = local.cloud_provider == "gcp" ? local.secret_backends : {}

  backend       = each.key
  project       = each.value.identifier
  credentials   = file("/path/to/gcp-service-account-key.json") # Replace with actual GCP credentials file
  token_scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
}

resource "vault_azure_secret_backend" "azure_backends" {
  for_each = local.cloud_provider == "azure" ? local.secret_backends : {}

  backend              = each.key
  tenant_id            = "your-tenant-id"                  # Replace with your Azure tenant ID
  client_id            = "your-client-id"                  # Replace with your Azure client ID
  client_secret        = "your-client-secret"              # Replace with your Azure client secret
  subscription_id      = each.value.identifier
}



locals {
  project_ids      = ["proj1", "proj2", "proj3"]         # Example list of GCP project IDs
  subscription_ids = ["sub1", "sub2", "sub3"]           # Example list of Azure subscription IDs
  app_id           = "my-app"                          # Example app_id
  cloud_provider   = "gcp"                             # Example cloud provider ("gcp" or "azure")
  
  # Determine identifiers based on the cloud provider
  identifiers = (
    local.cloud_provider == "gcp" ? local.project_ids : local.subscription_ids
  )
}

# Step 1: Fetch credentials from Vault
data "vault_generic_secret" "credentials" {
  for_each = toset(local.identifiers)

  path = "secret/data/${local.app_id}/${each.value}"
}

# Step 2: Write credentials to files dynamically
resource "local_file" "credentials_file" {
  for_each = data.vault_generic_secret.credentials

  filename = "${path.module}/credentials_${each.key}.json" # Output file path
  content  = jsonencode(each.value.data["data"])          # Write the fetched credentials
}

# Step 3: Use the credentials in GCP or Azure secret backends
resource "vault_gcp_secret_backend" "gcp_backends" {
  for_each = local.cloud_provider == "gcp" ? local.identifiers : {}

  backend       = "gcp_${local.app_id}_${each.value}"
  project       = each.value
  credentials   = local_file.credentials_file[each.key].filename # Use the dynamically created file
  token_scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
}

resource "vault_azure_secret_backend" "azure_backends" {
  for_each = local.cloud_provider == "azure" ? local.identifiers : {}

  backend              = "azure_${local.app_id}_${each.value}"
  subscription_id      = each.value
  tenant_id            = data.vault_generic_secret.credentials[each.key].data["data"]["tenant_id"]
  client_id            = data.vault_generic_secret.credentials[each.key].data["data"]["client_id"]
  client_secret        = data.vault_generic_secret.credentials[each.key].data["data"]["client_secret"]
}


locals {
  project_ids      = ["proj1", "proj2", "proj3"] # Example list of GCP project IDs
  subscription_ids = ["sub1", "sub2", "sub3"]   # Example list of Azure subscription IDs
  app_id           = "my-app"                  # Example app_id
  sdlc_name        = "dev"                     # Example SDLC environment
  lob              = ""                        # Example Line of Business
  cloud_provider   = "gcp"                     # Example cloud provider ("gcp" or "azure")
  
  # Namespace name based on `lob`
  vault_namespace = local.lob != "" ? "${local.lob}_${local.sdlc_name}_namespace" : "gcp_${local.sdlc_name}_namespace"

  # Determine identifiers based on cloud provider
  identifiers = local.cloud_provider == "gcp" ? local.project_ids : local.subscription_ids

  # Construct the map for secret backends
  secret_backends = {
    for id in local.identifiers : "${local.vault_namespace}/backend_${local.app_id}_${id}" => {
      id        = id
      namespace = local.vault_namespace
      path      = "${local.vault_namespace}/backend_${local.app_id}_${id}"
    }
  }
}

# Vault namespace creation (example, ensure the namespace exists in Vault)
resource "vault_namespace" "namespace" {
  name = local.vault_namespace
}

# Secret backend creation (iterates over the secret_backends map)
resource "vault_gcp_secret_backend" "gcp_backends" {
  for_each = local.cloud_provider == "gcp" ? local.secret_backends : {}

  backend       = each.value.path
  project       = each.value.id
  credentials   = file("/path/to/credentials.json") # Path to the GCP credentials
  token_scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
}

resource "vault_azure_secret_backend" "azure_backends" {
  for_each = local.cloud_provider == "azure" ? local.secret_backends : {}

  backend              = each.value.path
  subscription_id      = each.value.id
  tenant_id            = "example-tenant-id" # Replace with tenant ID
  client_id            = "example-client-id" # Replace with client ID
  client_secret        = "example-client-secret" # Replace with client secret
}

# Output the map for debugging purposes
output "secret_backends" {
  value = local.secret_backends
}






locals {
  # Define your project and subscription IDs
  project_ids      = ["proj1", "proj2", "proj3"] # GCP project IDs
  subscription_ids = ["sub1", "sub2", "sub3"]    # Azure subscription IDs
  app_id           = "my-app"                    # Application identifier
  sdlc_name        = "dev"                       # SDLC environment
  lob              = ""                          # Line of Business
  cloud_provider   = "gcp"                       # Cloud provider ("gcp" or "azure")

  # Determine the namespace based on Line of Business (lob)
  vault_namespace = local.lob != "" ? "${local.lob}_${local.sdlc_name}_namespace" : "${local.cloud_provider}_${local.sdlc_name}_namespace"

  # Select identifiers based on the cloud provider
  identifiers = local.cloud_provider == "gcp" ? local.project_ids : local.subscription_ids

  # Define roles and their capabilities
  roles = {
    admin    = ["create", "read", "update", "delete", "list"]
    dev      = ["create", "read", "update", "delete"]
    ro       = ["read", "list"]
    app_role = ["read"]
  }

  # Construct secret backend paths
  secret_backends = {
    for id in local.identifiers : "${id}_${local.app_id}" => {
      id        = id
      namespace = local.vault_namespace
      path      = "${local.vault_namespace}/backend_${local.app_id}_${id}"
    }
  }
}

# Ensure the Vault namespace exists
resource "vault_namespace" "namespace" {
  name = local.vault_namespace
}

# Fetch credentials from Vault based on the cloud provider
data "vault_generic_secret" "credentials" {
  for_each = toset(local.identifiers)

  path = "secret/data/${local.app_id}/${each.value}" # Vault path for credentials
}

# Create secret backends based on the cloud provider
resource "vault_gcp_secret_backend" "gcp_backends" {
  for_each = local.cloud_provider == "gcp" ? local.secret_backends : {}

  backend     = each.value.path
  project     = each.value.id
  credentials = data.vault_generic_secret.credentials[each.value.id].data["data"]["credentials"]
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  depends_on = [vault_namespace.namespace]
}

resource "vault_azure_secret_backend" "azure_backends" {
  for_each = local.cloud_provider == "azure" ? local.secret_backends : {}

  backend         = each.value.path
  subscription_id = each.value.id
  tenant_id       = data.vault_generic_secret.credentials[each.value.id].data["data"]["tenant_id"]
  client_id       = data.vault_generic_secret.credentials[each.value.id].data["data"]["client_id"]
  client_secret   = data.vault_generic_secret.credentials[each.value.id].data["data"]["client_secret"]

  depends_on = [vault_namespace.namespace]
}

# Create policies for each secret backend and role
resource "vault_policy" "secret_policies" {
  for_each = {
    for id, backend in local.secret_backends : id => backend
  }

  name   = each.key
  policy = join("\n", [
    for role, capabilities in local.roles : <<-EOT
      path "${each.value.path}/*" {
        capabilities = ${jsonencode(capabilities)}
      }
    EOT
  ])
}

# Output for debugging
output "secret_backends" {
  value = local.secret_backends
}


locals {
  # Define your project and subscription IDs
  project_ids      = ["proj1", "proj2", "proj3"] # GCP project IDs
  subscription_ids = ["sub1", "sub2", "sub3"]    # Azure subscription IDs
  app_id           = "my-app"                    # Application identifier
  cloud_provider   = "gcp"                       # Cloud provider ("gcp" or "azure")

  # Select identifiers based on the cloud provider
  identifiers = local.cloud_provider == "gcp" ? local.project_ids : local.subscription_ids

  # Construct secret backend paths
  secret_backends = {
    for id in local.identifiers : "${id}_${local.app_id}" => {
      id   = id
      path = "secret/data/${local.app_id}/${id}"
    }
  }
}

# Define policies for each secret backend
resource "vault_policy" "admin_policy" {
  for_each = local.secret_backends

  name   = "${each.key}_admin"
  policy = <<EOT
path "${each.value.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "developer_policy" {
  for_each = local.secret_backends

  name   = "${each.key}_dev"
  policy = <<EOT
path "${each.value.path}/*" {
  capabilities = ["create", "read", "update", "list"]
}
EOT
}

resource "vault_policy" "read_only_policy" {
  for_each = local.secret_backends

  name   = "${each.key}_ro"
  policy = <<EOT
path "${each.value.path}/*" {
  capabilities = ["read", "list"]
}
EOT
}

1. Reviewed the Terraform registry to find a resource for automating the rotation of the Azure SPN root.


2. No specific resource is available in the Terraform registry for this purpose.


3. The Vault generic secret resource can be used to rotate the secret, as it acts as an API for creating and updating.


4. This approach requires comprehensive testing.


5. Santhosh has requested the SPN. Once we receive it, I will initiate testing for root rotation in the sandbox environment.


locals {
  vault_namespace = (
    var.provider == "azure" && var.crown_jewel ? 
    "${var.appid}-${var.env}-crown_jewel-namespace" :
    
    var.provider == "azure" ? 
    "azure-${var.env}-namespace" :
    
    var.provider == "gcp" && length(var.lob) > 0 ? 
    "${var.lob}-sdlc-namespace" :
    
    var.provider == "gcp" ? 
    "gcp-sdlc-namespace" :

    "default-namespace"
  )
}
