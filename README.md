| Use Case | Description |                                                                                
| --- | --- |
| Vault Installation | Automate the installation of HashiCorp Vault on Linux servers using Ansible. This includes downloading and installing Vault via package managers or direct binaries and ensuring the Vault service is running.|
| Vault Configuration | Automate the configuration of the Vault server through Ansible, including setting up listeners, storage backends (e.g., Raft), seal configurations, and authentication settings (e.g., TLS, API).|
| High Availability (HA) Setup | Automate the setup of a Vault HA cluster with a shared storage backend (e.g., Consul). Ansible ensures proper node configuration for leader election, data replication, and high availability. |
| Cluster Initialization | Automate the initialization of Vault clusters using Ansible, which sets up the root token, enables the seal/unseal mechanism, and configures initial cluster settings. |
| Join Servers to Cluster | Automate the process of adding new Vault nodes to an existing Vault cluster. Ansible configures the new node to join the cluster, syncs data and ensures consistency. |
| Leader Election Management | Automate the management of leader election in the Vault cluster, ensuring the active leader is elected and in case of failure, another node is automatically promoted to leader. |
| Enable/Disable Vault Features | Automate enabling or disabling Vault server features, such as authentication methods (LDAP, AppRole) and secrets engines (KV, databases), using Ansible to ensure uniformity across all nodes. |
| Enable/Disable Audit Devices | Automate the enabling or disabling of Vault audit devices for logging operations (e.g., Syslog, file-based logging). Ansible ensures audit devices are consistently configured across nodes. |
| Backup Vault Data | Automate regular Vault data backups using Ansible, including the configuration and storage backend. Backup operations can be scheduled, ensuring Vault data is available for disaster recovery. |
| Restore Vault Data | Automate the restore process of Vault data from backups. Ansible ensures that data from backups can be restored on any Vault node after a failure or disaster recovery scenario. |
| Vault Upgrade Management | Automate the upgrade process of Vault servers. Ansible ensures that Vault is upgraded to the latest stable version with proper backup and rollback procedures to minimize disruption. |
| Health Check Automation | Automate periodic health checks on Vault servers using the Vault health API (/v1/sys/health). Ansible can trigger alerts when the Vault server fails the health check, ensuring early issue detection. |
| Metrics Collection for Monitoring | Automate the collection of Vault server metrics using Ansible and integrate them with monitoring systems (e.g., Grafana) for tracking performance and operational health. |
| Failover Automation | Automate failover mechanisms in case a Vault node fails. Ansible ensures that a new leader is elected, and failover operations occur seamlessly, ensuring high availability. |
| Cluster Configuration Sync | Automate the synchronization of Vault configuration across all nodes in the cluster using Ansible. This ensures that changes made to configuration are applied uniformly to prevent inconsistencies.
| Disaster Recovery Setup | Automate the disaster recovery setup for Vault, including secondary clusters, replication, and backup configurations. Ansible helps ensure that Vault can be restored to a working state in the event of a disaster. |
| Token Management (Server-Level) | Automate the creation, management, and revocation of tokens used for server-to-server communication within the Vault cluster, ensuring secure and controlled access. |
| Vault Auto-Unseal with Venafi Certs and HSM | Automate Vault's auto-unseal process using Venafi certificates for authentication and an HSM for key management. Ansible retrieves certificates from Venafi using its API, configures HSM to store keys securely, and updates the Vault configuration for auto-unsealing. After the configuration, Vault can automatically unseal itself using certificates stored in Venafi and cryptographic keys from the HSM during startup, eliminating the need for manual unsealing. |
| PR/DR (Primary/Recovery) Configuration | Automate the Primary/Recovery (PR/DR) configuration for Vault clusters. This involves setting up a primary Vault cluster and a recovery Vault cluster to handle disaster recovery. Ansible automates the replication of data, secrets, and configuration between the primary and recovery clusters. In the event of a failure or disaster, the recovery cluster takes over as the primary Vault instance, ensuring continued operation and minimal downtime. Ansible also handles failover and synchronization, ensuring a smooth transition between clusters. |
| Vault Log Rotation Configuration | Automate the configuration of log rotation for Vault logs to manage log file sizes and prevent excessive disk usage. Ansible can be used to configure logrotate or other log management tools, ensuring logs are rotated, archived, and deleted according to specified retention policies. This includes setting up configuration files for rotating logs based on size or time, ensuring that old logs are compressed and stored safely, and that system performance is not affected by excessive log accumulation. |


| **Test Case ID** | **Test Case Title**                                  | **Objective**                                                  | **Steps**                                                                                      | **Expected Results**                                                                             |
|------------------|----------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| TC-001            | Validate Vault Initialization                      | Ensure Vault is initialized and unsealed properly               | 1. Deploy Vault on Kubernetes. <br> 2. Initialize Vault. <br> 3. Unseal Vault with required keys. | Vault should be initialized and unsealed successfully, and Vault status should be active.       |
| TC-002            | Enable and Configure Secrets Engine                | Ensure secrets engine is enabled and configured                  | 1. Enable the secrets engine (e.g., database). <br> 2. Configure the secrets engine.            | Secrets engine should be enabled and configured successfully.                                    |
| TC-003            | Create Dynamic Secret Role                         | Ensure a role for dynamic secrets is created                     | 1. Create a role with the correct policy and configuration.                                     | Role should be created successfully and associated with the secrets engine.                      |
| TC-004            | Generate Dynamic Secrets                           | Ensure dynamic secrets are generated on demand                   | 1. Request dynamic secrets via the Vault API or CLI.                                              | Dynamic secrets should be created and returned successfully.                                     |
| TC-005            | Validate Secret Lease Expiration and Renewal       | Ensure secret expiration and renewal work as expected            | 1. Check the lease duration of the secret. <br> 2. Attempt to renew the lease.                   | Lease should expire or renew as per the configuration.                                            |
| TC-006            | Automatic Secret Update in Kubernetes Pods         | Ensure Kubernetes pods pick up secret updates automatically      | 1. Update the secret in Vault. <br> 2. Verify if the change reflects in the Kubernetes pod.      | Kubernetes pods should reflect the updated secret automatically without manual intervention.     |
| TC-007            | Access Control Validation                          | Ensure access control policies are respected                     | 1. Try to access secrets with valid and invalid policies.                                         | Access should be granted for valid policies and denied for invalid ones.                         |
| TC-008            | Secret Revocation                                  | Ensure secret revocation works correctly                         | 1. Revoke a secret using the Vault API or CLI.                                                    | The secret should be revoked and no longer accessible.                                            |



| **Test Case ID** | **Test Case Title**                        | **Objective**                                                | **Steps**                                                                                 | **Expected Results**                                                             |
|------------------|------------------------------------------|--------------------------------------------------------------|------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| SE-001            | Validate Secret Lease Expiration         | Ensure dynamic secrets expire after the configured lease time | 1. Configure secret lease duration in Vault. <br> 2. Generate dynamic secret. <br> 3. Wait for lease duration to expire. | Secret should be inaccessible after lease expiration.                           |
| SE-002            | Test Secret Renewal Before Expiration    | Ensure secrets can be renewed before they expire              | 1. Generate dynamic secret. <br> 2. Renew the secret lease before expiration.              | Lease duration should extend successfully.                                        |
| SE-003            | Validate Automatic Secret Revocation     | Ensure secrets are automatically revoked after expiration     | 1. Configure secret lease duration. <br> 2. Wait for lease duration to pass.                | Secret should be automatically revoked and no longer accessible.                |
| SE-004            | Check Secret Rotation on Expiry          | Ensure a new secret is generated after old one expires        | 1. Generate dynamic secret. <br> 2. Wait for secret expiration. <br> 3. Request a new secret. | A new, different secret should be generated after expiration of the old one.    |
| SE-005            | Handle Secret Expiry Notifications       | Ensure expiry events are properly logged and notified         | 1. Configure Vault audit log and notification settings. <br> 2. Let secret expire.          | Expiry event should be logged and notified as configured.                        |


| **Test Case ID** | **Test Case Title**                            | **Objective**                                                 | **Steps**                                                                                      | **Expected Results**                                                                            |
|------------------|------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| SR-001            | Validate Dynamic Secret Retrieval             | Ensure secrets can be retrieved on demand from Vault            | 1. Enable the secrets engine in Vault. <br> 2. Create a role for dynamic secrets. <br> 3. Request a dynamic secret. | Secret should be created and returned successfully.                                              |
| SR-002            | Test Secret Synchronization with Kubernetes    | Ensure secrets are automatically synchronized with Kubernetes   | 1. Configure Vault Agent or CSI driver for secret sync. <br> 2. Update secret in Vault. <br> 3. Verify the change in Kubernetes. | Kubernetes secret should reflect the updated Vault secret automatically.                        |
| SR-003            | Handle Secret Regeneration                     | Ensure secret regeneration creates a new, valid secret          | 1. Revoke an existing secret. <br> 2. Request a new secret.                                       | A newly generated secret should be returned, different from the revoked one.                     |
| SR-004            | Validate Secret Access Control                  | Ensure only authorized roles can access specific secrets         | 1. Configure policies in Vault. <br> 2. Try accessing secrets with valid and invalid policies.   | Access should be granted for valid policies and denied for invalid ones.                         |
| SR-005            | Test Secret Consistency Across Multiple Pods    | Ensure secret updates are consistent across multiple Kubernetes pods | 1. Deploy multiple pods accessing the same secret. <br> 2. Update the secret in Vault. <br> 3. Verify the secret in all pods. | All pods should reflect the updated secret consistently.                                           |




| **Test Case ID** | **Test Case Title**                              | **Objective**                                                  | **Steps**                                                                                      | **Expected Results**                                                                            |
|------------------|------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| OCP-001           | Validate Static Secret Export from Source Vault Cluster | Ensure static secrets are exported correctly from the source Vault on OCP cluster | 1. Access the source Vault on OCP cluster. <br> 2. Identify and select the static secrets for export. <br> 3. Export secrets using Vault CLI or API. | Static secrets should be successfully exported in the correct format.                           |
| OCP-002           | Verify Secret Format and Integrity              | Ensure exported secrets maintain their integrity and format      | 1. Inspect the exported secret files. <br> 2. Validate encoding, structure, and data integrity. | Secrets should retain their original structure and data without corruption.                      |
| OCP-003           | Import Static Secrets to Target Vault Cluster         | Ensure static secrets are imported correctly into the target Vault on OCP cluster | 1. Access the target Vault on OCP cluster. <br> 2. Use Vault CLI or API to import the exported secrets. | Secrets should be successfully created and visible in the target Vault cluster.                        |
| OCP-004           | Validate Secret Accessibility in Target Cluster | Ensure imported secrets are accessible to the appropriate applications | 1. Deploy an application in the target cluster. <br> 2. Reference the imported secrets in the application’s configuration. | Application should be able to access the imported secrets without issues.                        |
| OCP-005           | Test Synchronization Across Vault Clusters            | Ensure secrets remain synchronized across Vault on OCP clusters if required | 1. Modify a static secret in the source Vault cluster. <br> 2. Trigger a synchronization process. <br> 3. Verify the secret update in the target Vault cluster. | Updated secret should be reflected in the target Vault cluster after synchronization.                  |
| OCP-006           | Handle Secret Conflict Resolution               | Ensure conflicts between source and target Vault secrets are handled properly | 1. Create a static secret with the same name in both Vault clusters but different values. <br> 2. Attempt migration. | Conflict resolution policy should apply, and expected behavior (overwrite, skip, merge) should occur. |
| OCP-007           | Ensure Multi-Tenant Secret Isolation            | Ensure secrets for different tenants remain isolated and secure  | 1. Configure Vault namespaces or policies for multi-tenant setup. <br> 2. Create static secrets for multiple tenants. <br> 3. Attempt to access secrets from different tenant scopes. | Each tenant should only be able to access its own secrets, and cross-tenant access should be denied. |
| OCP-008           | Test Secret Access Control for Multiple Tenants | Ensure proper RBAC and policies for multi-tenant secret management | 1. Define RBAC roles and policies in Vault for different tenants. <br> 2. Assign roles to users and applications. <br> 3. Attempt to access secrets based on role permissions. | Users and applications should only access secrets allowed by their assigned roles and policies. |
| OCP-009           | Validate Secret Update Propagation Across Tenants | Ensure secret updates for one tenant don’t affect others          | 1. Update a static secret for one tenant in the Vault cluster. <br> 2. Verify secret value across other tenants. | Only the updated tenant’s secret should reflect the change; other tenants' secrets should remain unchanged. |





| **Test Case ID** | **Test Case Title**                              | **Objective**                                                  | **Steps**                                                                                      | **Expected Results**                                                                            |
|------------------|------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| AUDIT-001         | Enable Vault Audit Logging                      | Ensure Vault audit logging is enabled and operational           | 1. Access the Vault configuration. <br> 2. Enable audit devices (e.g., file, syslog). <br> 3. Verify audit logging status. | Vault audit logging should be enabled and confirmed as active.                                  |
| AUDIT-002         | Capture Secret Access Requests                  | Ensure secret access requests are being captured in audit logs   | 1. Access secrets from different applications and tenants. <br> 2. Perform read, write, and delete operations on secrets. <br> 3. Review Vault audit logs. | Every access request should be logged with timestamp, user identity, and operation details.      |
| AUDIT-003         | Validate Audit Log Format and Completeness      | Ensure audit logs are correctly formatted and contain complete data | 1. Review a sample of audit logs. <br> 2. Verify log format (JSON, plaintext, etc.). <br> 3. Ensure logs contain timestamp, user, accessed secret, and operation. | Audit logs should follow the expected format and include all relevant access information.        |
| AUDIT-004         | Test Audit Log Retention and Rotation           | Ensure audit logs are retained and rotated as per policy         | 1. Configure retention and rotation policies in Vault audit logging. <br> 2. Generate high-volume access activity. <br> 3. Check if old logs are archived and new logs created. | Audit logs should rotate and retain according to configured policy without data loss.            |
| AUDIT-005         | Monitor Unauthorized Access Attempts            | Ensure unauthorized access attempts are captured in audit logs   | 1. Attempt to access secrets without appropriate permissions. <br> 2. Review Vault audit logs. | Unauthorized access attempts should be logged with relevant error details and user information.  |



| **Test Case ID** | **Test Case Title**                              | **Objective**                                                  | **Steps**                                                                                      | **Expected Results**                                                                            |
|------------------|------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| MT-001            | Ensure Multi-Tenant Secret Isolation            | Ensure secrets for different tenants remain isolated and secure  | 1. Configure Vault namespaces or policies for multi-tenant setup. <br> 2. Create static secrets for multiple tenants. <br> 3. Attempt to access secrets from different tenant scopes. | Each tenant should only be able to access its own secrets, and cross-tenant access should be denied. |
| MT-002            | Test Secret Access Control for Multiple Tenants | Ensure proper RBAC and policies for multi-tenant secret management | 1. Define RBAC roles and policies in Vault for different tenants. <br> 2. Assign roles to users and applications. <br> 3. Attempt to access secrets based on role permissions. | Users and applications should only access secrets allowed by their assigned roles and policies. |
| MT-003            | Validate Secret Update Propagation Across Tenants | Ensure secret updates for one tenant don’t affect others          | 1. Update a static secret for one tenant in the Vault cluster. <br> 2. Verify secret value across other tenants. | Only the updated tenant’s secret should reflect the change; other tenants' secrets should remain unchanged. |
| MT-004            | Test Secret Expiry and Renewal for Multi-Tenant Setup | Ensure secret expiry and renewal are properly handled per tenant | 1. Configure secret TTL for each tenant’s secrets. <br> 2. Wait for the secret’s TTL to expire. <br> 3. Renew the secret and verify accessibility. | Expired secrets should become inaccessible, and renewed secrets should be accessible without issues. |
| MT-005            | Monitor Access Logs for Multi-Tenant Secrets     | Ensure audit logs capture tenant-specific secret access events   | 1. Enable Vault audit logging. <br> 2. Access secrets from different tenant scopes. <br> 3. Review Vault audit logs. | Audit logs should clearly show tenant-specific access, including user identity and accessed secrets. |






..........

Here’s a clean and detailed README.md for setting up a Harness connector for HashiCorp Vault:

# Harness Connector for HashiCorp Vault

This repository provides instructions and configuration for creating a Harness connector to integrate with HashiCorp Vault. This allows Harness to securely retrieve secrets stored in your Vault for use in deployments and pipelines.

## Prerequisites

Before setting up the connector, ensure you have the following:
- Access to a HashiCorp Vault instance.
- A Vault role with permissions to read secrets.
- Vault server URL and authentication credentials (Token, AppRole, or Kubernetes Auth).
- Access to a Harness account with permissions to create secrets managers.

## 1. Configure HashiCorp Vault

1. **Enable AppRole Authentication (if using AppRole)**:
```bash
vault auth enable approle

2. Create a Policy with Read Access to Secrets:



# policy.hcl
path "secret/data/*" {
  capabilities = ["read"]
}

3. Apply the Policy:



vault policy write harness-policy policy.hcl

4. Create an AppRole:



vault write auth/approle/role/harness-role \
  token_policies="harness-policy" \
  secret_id_ttl=0 \
  token_num_uses=0 \
  token_ttl=20m \
  token_max_ttl=30m

5. Fetch the Role ID and Secret ID:



vault read auth/approle/role/harness-role/role-id
vault write -f auth/approle/role/harness-role/secret-id


---

2. Create the Harness Connector

1. Navigate to Harness: Go to your Harness account and select your project or organization.


2. Create a New Connector:

Go to Connectors and click + New Connector.

Choose Secret Manager and then select HashiCorp Vault.



3. Configure Vault Details:

Vault URL: https://<your-vault-server>:8200

Authentication Method: Choose one of the following:

Token: Provide the Vault token.

AppRole: Enter the Role ID and Secret ID created earlier.

Kubernetes Auth: Provide the necessary Kubernetes token and configuration.


Secret Engine Version: Choose KV Version 1 or KV Version 2 depending on your Vault setup.

Secret Engine Path: The base path where secrets are stored (e.g., secret/).

Namespace (if using Enterprise): Enter the Vault namespace if applicable.



4. Test and Save the Connector:

Click Test Connection to verify the setup.

If successful, click Save.





---

3. Accessing Secrets in Harness

Once the connector is set up, you can use secrets from Vault in your pipelines and deployments:

1. Create a Secret:

Go to Secrets and click + New Secret.

Choose Secret Manager and select the HashiCorp Vault connector.

Provide the path to the secret in Vault (e.g., secret/data/my-secret).



2. Reference the Secret: Use the secret in your pipeline by referencing it like:



environmentVariables:
  MY_SECRET: <+secrets.getValue("my-vault-secret")>


---

4. Troubleshooting

"Permission Denied" Errors: Ensure the Vault policy grants read access to the path.

"Invalid Path" Errors: Confirm the secret engine path and version.

Connection Failures: Check Vault URL, network access, and authentication method.



---

5. Resources

Harness Documentation

HashiCorp Vault Documentation


Let me know if you’d like me to refine or add anything!



Here's a high-level comparison between the Vault CSI provider and the Vault Injector:

Sure! Here's the comparison in a simple README-style format:


---

Vault CSI Provider vs Vault Agent Injector

This table provides a high-level comparison between using the Vault CSI Provider and the Vault Agent Injector for injecting secrets into Kubernetes pods.


---

Let me know if you want this tailored for a specific use case or platform like OpenShift.

On some platforms (especially mobile apps), table formatting using Markdown might not render as a true table you can easily copy. Instead, it shows up as plain text with pipes (|) and dashes (-), which isn't selectable as a table.

Here’s an alternative version using simple text formatting that should be easier to copy from:


---

Vault CSI Provider vs Vault Agent Injector

1. Secret Injection Method

CSI Provider: Mounts secrets as files via CSI volume

Agent Injector: Injects secrets as environment variables or files



2. Dependency

CSI Provider: Uses CSI driver, no sidecar container needed

Agent Injector: Requires Vault Agent sidecar per pod



3. Update Mechanism

CSI Provider: Supports secret refresh via file rotation

Agent Injector: Supports auto-renewal and re-authentication



4. Resource Overhead

CSI Provider: Lower (no extra container per pod)

Agent Injector: Higher (runs a Vault Agent sidecar per pod)





---

Let me know if you want this in a downloadable format (like a .md file).











Here’s the migration plan formatted for Confluence using standard formatting macros and headings. You can paste this directly into a Confluence page editor (using the rich-text mode or wiki markup if enabled).


---

Vault Migration Plan: Non-Prod Data to Dedicated Vault Cluster


---

Overview

This document outlines the strategy to migrate non-production secrets, auth methods, and groups from the existing shared Vault Enterprise cluster (prod + non-prod) to a new, dedicated non-prod Vault cluster with a separate URL.


---

Goals

Isolate non-prod workloads from the current production Vault cluster.

Ensure secure and seamless migration with minimal disruption.

Maintain separate operational, auditing, and security boundaries.



---

Migration Strategy

We will use Vault Enterprise Performance Replication with mount filters to replicate only the required non-prod paths and authentication configurations to the new cluster.


---

What Will Be Migrated


---

What Will NOT Be Migrated


---

Migration Phases

Phase 1: Preparation

[ ] Provision a new Vault Enterprise cluster (non-prod) with separate URL

[ ] Ensure version and plugin parity with the existing cluster

[ ] Enable Performance Replication on the existing (prod) Vault if not already enabled



---

Phase 2: Connect the New Cluster as a Secondary

[ ] Generate a secondary token on the existing Vault

[ ] Connect the new Vault as a secondary using that token



---

Phase 3: Apply Mount Filters

[ ] Create a file mounts.txt listing allowed paths (example below)

[ ] Use a script to configure mount filters via the Vault API


Example mounts.txt:

kv/nonprod/*
secret/devops/*
transit/dev-team/*
auth/ldap-nonprod


---

Phase 4: Validation

[ ] Validate replicated secrets and mount structure

[ ] Validate LDAP login and group memberships

[ ] Validate application connectivity using test workloads



---

Phase 5: Promotion

[ ] Promote the non-prod Vault secondary to standalone

[ ] Break replication link from prod

[ ] Enable local root token access or identity login

[ ] Configure audit log sinks, storage backends, and alerting



---

Phase 6: Cutover

[ ] Update all non-prod app configurations to point to the new Vault URL

[ ] Notify impacted teams

[ ] Retire or disable non-prod mounts on the prod Vault (optional)



---

Benefits of This Approach


---

Why Not Terraform?

Terraform is not suitable for Vault data migration because:

It cannot extract existing secrets or dynamic data

It does not support replication or live data sync

Terraform’s state files may expose sensitive data

It cannot replicate identity groups, leases, or token metadata


Vault Enterprise Performance Replication is the only supported, secure, and scalable method for migrating Vault data between clusters.


---

Post-Migration Tasks

[ ] Review and align non-prod policies

[ ] Enable audit logging and alerting

[ ] Set up backup schedules

[ ] Document new Vault endpoints and access methods



---

Let me know if you'd like a downloadable version (Markdown, Word, or PDF), or want this pre-filled into a Confluence content export or template!



# Vault Migration Plan: Non-Prod Data to Dedicated Vault Cluster

## Overview

This document outlines the strategy to migrate **non-production secrets, auth methods, and groups** from the existing shared **Vault Enterprise cluster (prod + non-prod)** to a new, dedicated **non-prod Vault cluster** with a separate URL.

---

## Goals

- Isolate **non-prod workloads** from the current production Vault cluster.
- Ensure secure and seamless migration with minimal disruption.
- Maintain separate operational, auditing, and security boundaries.

---

## Migration Strategy

We will use **Vault Enterprise Performance Replication with mount filters** to replicate only the required non-prod paths and authentication configurations to the new cluster.

---

## What Will Be Migrated

| Component         | Description                             |
|------------------|-----------------------------------------|
| **KV secrets**    | Paths like `kv/nonprod/*`, `secret/devops/*` |
| **Transit secrets** | e.g., `transit/dev-team/`              |
| **LDAP auth methods** | e.g., `auth/ldap-nonprod`           |
| **Identity groups** | Only groups linked to replicated auth mounts |
| **Policies**      | Automatically replicated if tied to replicated paths |

---

## What Will NOT Be Migrated

| Excluded          | Reason                                          |
|------------------|-------------------------------------------------|
| **Prod secrets**   | Not in the allowed paths list                  |
| **Leases / Tokens**| Vault replication does not replicate leases or tokens |
| **Root tokens**    | Must be managed independently                 |
| **Secrets outside filters** | Strict path-based inclusion is enforced |

---

## Migration Phases

### Phase 1: Preparation

- [ ] Provision a new Vault Enterprise cluster (non-prod) with separate URL
- [ ] Ensure version and plugin parity with the existing cluster
- [ ] Enable Performance Replication on the existing (prod) Vault if not already enabled

---

### Phase 2: Connect the New Cluster as a Secondary

- [ ] Generate a **secondary token** on the existing Vault
- [ ] Connect the new Vault as a **secondary** using that token

---

### Phase 3: Apply Mount Filters

- [ ] Create a file `mounts.txt` listing allowed paths (example below)
- [ ] Use a script to configure mount filters via the Vault API

**Example `mounts.txt`:**



---

### Phase 4: Validation

- [ ] Validate replicated secrets and mount structure
- [ ] Validate LDAP login and group memberships
- [ ] Validate application connectivity using test workloads

---

### Phase 5: Promotion

- [ ] Promote the non-prod Vault secondary to standalone
- [ ] Break replication link from prod
- [ ] Enable local root token access or identity login
- [ ] Configure audit log sinks, storage backends, and alerting

---

### Phase 6: Cutover

- [ ] Update all non-prod app configurations to point to the new Vault URL
- [ ] Notify impacted teams
- [ ] Retire or disable non-prod mounts on the prod Vault (optional)

---

## Benefits of This Approach

| Benefit             | Description                                   |
|---------------------|-----------------------------------------------|
| **Isolation**        | Complete environment separation               |
| **Security**         | Minimize accidental cross-environment access  |
| **Audit Clarity**    | Separate logging and monitoring for prod vs non-prod |
| **Operational Flexibility** | Easier upgrades, testing, and plugin trials |

---

## Why Not Terraform?

Terraform is not suitable for Vault data migration because:

- It **cannot extract existing secrets** or dynamic data
- It **does not support replication or live data sync**
- Terraform’s state files may **expose sensitive data**
- It cannot replicate **identity groups, leases, or token metadata**

Vault Enterprise Performance Replication is the **only supported, secure, and scalable** method for migrating Vault data between clusters.

---

## Post-Migration Tasks

- [ ] Review and align non-prod policies
- [ ] Enable audit logging and alerting
- [ ] Set up backup schedules
- [ ] Document new Vault endpoints and access methods