# Vault Access Policy and Auth Method Matrix

## Overview

This document defines access policies for various user roles and how they authenticate with HashiCorp Vault. It provides a policy matrix for authentication methods, capabilities, and secret access paths based on user roles.

---

## Roles and Responsibilities

| Role               | Responsibilities                                                  |
|--------------------|-------------------------------------------------------------------|
| **Developer**       | Consumes secrets for dev/test environments.                      |
| **Lead Developer**  | Manages devs, updates secrets, owns project scope.               |
| **Implementer**     | Configures Vault integrations, handles automation (CI/CD).       |
| **Auditor**         | Audits Vault access, reads metadata/logs.                        |
| **Vault Admin**     | Manages all Vault components and system configuration.           |
| **Automation (CI/CD)** | Pipeline identity used to fetch secrets automatically.        |

---

## Authentication Method Matrix

| Auth Method   | Developer | Lead Developer | Implementer | Auditor | Vault Admin | Automation (CI/CD) |
|---------------|-----------|----------------|-------------|---------|-------------|---------------------|
| **LDAP**      | Yes       | Yes            | Optional    | Yes     | Yes         | No                  |
| **Cert**      | Optional  | Optional       | Yes         | No      | Yes         | Optional            |
| **AppRole**   | No        | No             | Yes         | No      | Yes         | Yes                 |
| **Token**     | No        | No             | Optional    | No      | Yes         | Optional            |
| **OIDC**      | Yes       | Yes            | No          | Yes     | Optional    | No                  |

---

## Policy Mapping

| Role               | Policy Names                          | Capabilities                                      |
|--------------------|----------------------------------------|--------------------------------------------------|
| **Developer**       | `dev-read`, `kv-read`, `project-a-read`   | `read`, `list`                                 |
| **Lead Developer**  | `dev-write`, `project-a-admin`            | `create`, `update`, `read`, `list`              |
| **Implementer**     | `infra-admin`, `approle-manager`          | `create`, `update`, `read`, `list`              |
| **Auditor**         | `audit-read`, `sys-read`                  | `read`, `list` (no secret read)                 |
| **Vault Admin**     | `admin`, `sys-admin`, `auth-admin`        | `create`, `read`, `update`, `delete`, `sudo`    |
| **Automation**      | `ci-role-policy`, `kv-ci-access`          | `read`, `list`                                  |

---

## Recommended Secret Path Access

| Role               | Secret Paths                    | Capabilities                              |
|--------------------|----------------------------------|-------------------------------------------|
| **Developer**       | `secret/data/dev/<app>`          | `read`, `list`                            |
| **Lead Developer**  | `secret/data/dev/<app>`          | `create`, `update`, `read`, `list`        |
| **Implementer**     | `auth/approle/role/*`, `sys/*`   | `create`, `read`, `update`, `list`        |
| **Auditor**         | `sys/audit`, `sys/internal/*`    | `read`, `list` (no secrets)               |
| **Vault Admin**     | `*` (all paths)                  | Full permissions                          |
| **Automation**      | `secret/data/ci/<app>`           | `read`, `list`                            |

---

## Sample Developer Policy

```hcl
path "secret/data/dev/*" {
  capabilities = ["read", "list"]
}

path "secret/metadata/dev/*" {
  capabilities = ["list"]
}



path "secret/data/ci/frontend" {
  capabilities = ["read"]
}

path "auth/token/create" {
  capabilities = ["update"]
}


group "dev-team" {
  policies = ["dev-read"]
}

group "leads" {
  policies = ["dev-write"]
}

group "vault-admins" {
  policies = ["admin"]
}