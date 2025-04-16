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