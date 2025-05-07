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