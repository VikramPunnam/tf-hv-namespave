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






# Vault Agent Modes: `agent.prePopulateOnly=true` vs Sidecar Mode

This document compares two ways to use Vault Agent when injecting secrets into Kubernetes pods:  
1. **`agent.prePopulateOnly=true`** — Agent runs once at startup and exits  
2. **Continuous Sidecar** — Agent runs alongside the application for the pod's lifetime

| **Aspect**                         | **`agent.prePopulateOnly=true` (Init Mode)**                    | **Continuously Running Vault Agent Sidecar**                  |
|-----------------------------------|------------------------------------------------------------------|---------------------------------------------------------------|
| **Agent Lifecycle**               | Runs once at pod startup, then exits                            | Runs as a sidecar container for the pod’s lifetime            |
| **Resource Usage**                | Low (only at startup)                                           | Higher (constant CPU/memory usage)                            |
| **Secret Access Timing**         | Secrets available at startup only                               | Secrets available at startup and during runtime               |
| **Secret Auto-Rotation**         | Not supported                                                    | Supported (via live file updates or API calls)                |
| **Lease Renewal**                | Not handled                                                      | Agent can renew leases automatically                          |
| **Security Surface**             | Minimal (no running agent)                                       | Larger (agent always running and connected to Vault)          |
| **Startup Time**                 | Fast (agent exits quickly)                                      | Slightly slower (agent must initialize and remain running)    |
| **Application Complexity**       | Simpler (no sidecar communication needed)                       | Slightly more complex (needs coordination with agent)         |
| **Ideal Use Cases**              | Static secrets, batch jobs, ephemeral pods                      | Dynamic secrets, long-running apps needing rotation           |
| **Secret Updates Require**       | Pod restart or redeploy                                          | No restart; agent updates secrets in-place                    |
| **Logging & Debugging**          | Simpler (single init log)                                       | More verbose (continuous logging from agent)                  |

---

## When to Use `agent.prePopulateOnly=true`

- Your application only needs secrets at startup
- Secrets don’t change frequently
- You want to minimize sidecar overhead
- You're running batch or short-lived jobs

## When to Use a Vault Agent Sidecar

- Secrets rotate often or have short TTLs
- You use dynamic secrets (e.g., database credentials)
- You want seamless secret updates without pod restarts

---

## Example Annotation for `agent.prePopulateOnly=true`

```yaml
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/role: "my-app-role"
vault.hashicorp.com/agent-pre-populate-only: "true"
vault.hashicorp.com/agent-inject-secret-config.txt: "secret/data/my-app/config"
vault.hashicorp.com/agent-inject-template-config.txt: |
  {{- with secret "secret/data/my-app/config" -}}
  DB_USERNAME={{ .Data.data.username }}
  DB_PASSWORD={{ .Data.data.password }}
  {{- end }}









# Vault Role Capabilities and Policy Mapping

## Overview

This section defines what each role can **do in Vault**, their **capabilities**, and the **policies** assigned. This helps ensure least privilege access is enforced according to responsibilities.

---

## Developer

| Capability       | Description                                       | Vault Path Example             | Policies           |
|------------------|---------------------------------------------------|--------------------------------|--------------------|
| `read`, `list`   | Read application secrets and list metadata        | `secret/data/dev/<app>`        | `dev-read`, `kv-read` |
| `list`           | List secrets under dev environment                | `secret/metadata/dev/`         | `kv-read`          |
| `read`           | Read dynamic credentials (optional, e.g., DB)     | `database/creds/dev-role`      | `db-read` (optional) |

> **Note**: Developers are restricted to read-only access for specific paths.

---

## Lead Developer

| Capability              | Description                                            | Vault Path Example             | Policies             |
|-------------------------|--------------------------------------------------------|--------------------------------|----------------------|
| `create`, `update`      | Write and update secrets                               | `secret/data/dev/<app>`        | `dev-write`          |
| `read`, `list`          | Read secrets and list paths                            | `secret/data/dev/<app>`        | `kv-read`, `dev-write` |
| `read`, `list`          | View AppRole metadata or tokens (if needed)            | `auth/approle/role/<app>`      | `approle-read` (optional) |

> **Note**: Lead Developers can manage secrets for their applications, but not rotate auth backends or system-level paths.

---

## Implementer (CI/CD / Platform Engineer)

| Capability              | Description                                                | Vault Path Example                  | Policies               |
|-------------------------|------------------------------------------------------------|-------------------------------------|------------------------|
| `create`, `update`      | Create/update secrets and auth roles                       | `secret/data/ci/<app>`, `auth/*`    | `ci-write`, `infra-admin` |
| `read`, `list`          | Read secrets and configuration                             | `secret/data/*`, `sys/*`            | `infra-admin`          |
| `create`, `read`        | Create tokens, AppRole credentials                         | `auth/approle/role/<app>`, `token/` | `approle-manager`      |
| `update`                | Rotate credentials or update AppRole config                | `auth/approle/role/<app>/secret-id` | `approle-manager`      |

> **Note**: This role handles automation tasks and Vault provisioning.

---

## Vault Admin

| Capability              | Description                                                  | Vault Path Example              | Policies                 |
|-------------------------|--------------------------------------------------------------|---------------------------------|--------------------------|
| `sudo`                  | Full access to Vault including policy creation               | `sys/*`, `auth/*`, `secret/*`   | `admin`, `sys-admin`     |
| `create`, `update`, `delete` | Manage all secrets, auth methods, and backends          | `*`                             | `admin`                  |
| `read`, `list`          | List and read all paths and configurations                   | `*`                             | `admin`, `auth-admin`    |

> **Note**: Reserved for core Vault operators with unrestricted access.

---

## Auditor

| Capability       | Description                                      | Vault Path Example               | Policies       |
|------------------|--------------------------------------------------|----------------------------------|----------------|
| `read`, `list`   | Read audit logs, metadata, and system internals  | `sys/audit`, `sys/internal/`     | `audit-read`   |
| `read`           | Access `/sys/leases`, `/sys/metrics`             | `sys/leases`, `sys/metrics`      | `sys-read`     |

> **Note**: Auditors cannot read secrets, only system metadata.

---

## Automation (CI/CD)

| Capability       | Description                                      | Vault Path Example             | Policies             |
|------------------|--------------------------------------------------|--------------------------------|----------------------|
| `read`, `list`   | Read secrets needed for deployment pipelines     | `secret/data/ci/<app>`         | `ci-role-policy`     |
| `update`         | Request tokens using AppRole                     | `auth/approle/login`           | `kv-ci-access`       |

> **Note**: This identity is typically used by pipeline runners or automation tools.

---

## Summary Table

| Role             | Capabilities                                     | Policies                                |
|------------------|--------------------------------------------------|-----------------------------------------|
| **Developer**     | `read`, `list`                                   | `dev-read`, `kv-read`, `db-read` (opt)  |
| **Lead Developer**| `read`, `list`, `create`, `update`              | `dev-write`, `project-a-admin`          |
| **Implementer**   | `read`, `list`, `create`, `update`, `delete`    | `infra-admin`, `approle-manager`        |
| **Vault Admin**   | All (`sudo`, full control)                      | `admin`, `sys-admin`, `auth-admin`      |
| **Auditor**       | `read`, `list` (no secret data access)          | `audit-read`, `sys-read`                |
| **Automation**    | `read`, `list`, `update` (AppRole login only)   | `ci-role-policy`, `kv-ci-access`        |