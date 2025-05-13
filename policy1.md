Absolutely — here is a final, complete, production-ready access model for Vault, integrating:

User roles (application-side and Vault-side),

Secret engines (kv-v2, Azure, GCP, database, transit),

Capabilities scoped to specific paths,

LDAP-based role mapping,

Policy and auth configurations.


Everything is formatted for direct copy-paste into a README.md file for use in documentation or Confluence.


---

# 🔐 Vault Access Model: Role-Based Policy and LDAP Mapping

This document defines the full access control model for HashiCorp Vault using LDAP-based authentication, secret engine segregation, and role-based policy assignment for application and Vault teams.

---

## 🧑‍💻 Role Categories

### Application-Side Roles

| Role            | Description                                                      |
|------------------|------------------------------------------------------------------|
| **Developer**       | Reads application-level secrets (e.g., `secret/data/dev/`).       |
| **Lead Developer**  | Writes and manages team secrets within scope.                    |
| **Implementer**     | Sets up CI/CD integrations, AppRole, and manages `ci-*` secrets. |

### Vault-Side Roles

| Role             | Description                                                        |
|------------------|--------------------------------------------------------------------|
| **Vault Admin**      | Full system-wide access to Vault components and configurations.   |
| **Vault Auditor**    | Read-only access to audit logs and system metadata.              |

---

## 🔑 Secret Engine Scope by Role

| Secret Engine | Developer           | Lead Developer        | Implementer (Scoped)      | Vault Admin     | Auditor         |
|---------------|---------------------|------------------------|----------------------------|------------------|------------------|
| **kv-v2**     | `read`, `list`      | `create`, `read`, `update`, `list` | `create`, `read`, `update`, `list` on `ci/*` | Full             | ❌                |
| **Azure**     | ❌                  | ❌                     | `read`, `create`, `update`, `list` on `roles/ci-*` | Full             | ❌                |
| **GCP**       | ❌                  | ❌                     | `read`, `create`, `update`, `list` on `roles/ci-*` | Full             | ❌                |
| **Database**  | `read` (dynamic)    | `read` (dynamic)       | `read`, `create`, `list` on `roles/ci-*`        | Full             | ❌                |
| **Transit**   | ❌                  | ❌                     | `update` on `encrypt/ci-*`                      | Full             | ❌                |
| **auth/approle** | ❌               | ❌                     | `read`, `create`, `update`, `list` on `ci-*`    | Full             | ❌                |
| **Audit Logs**| ❌                  | ❌                     | ❌                                            | Full             | `read`, `list`     |

---

## 📁 Vault Policy Snippets

### `dev-read.hcl` – Developer
```hcl
path "secret/data/dev/*" {
  capabilities = ["read"]
}
path "secret/metadata/dev/*" {
  capabilities = ["list"]
}
path "database/creds/dev-role" {
  capabilities = ["read"]
}


---

team-write.hcl – Lead Developer

path "secret/data/dev/*" {
  capabilities = ["create", "read", "update"]
}
path "secret/metadata/dev/*" {
  capabilities = ["list"]
}


---

ci-infra-limited.hcl – Implementer (Scoped)

# kv-v2 for CI/CD
path "secret/data/ci/*" {
  capabilities = ["create", "read", "update", "list"]
}
path "secret/metadata/ci/*" {
  capabilities = ["list"]
}

# Azure and GCP roles for CI
path "azure/roles/ci-*" {
  capabilities = ["create", "read", "update", "list"]
}
path "gcp/roles/ci-*" {
  capabilities = ["create", "read", "update", "list"]
}

# AppRole for CI/CD
path "auth/approle/role/ci-*" {
  capabilities = ["create", "read", "update", "list"]
}

# Database dynamic creds for CI/CD
path "database/roles/ci-*" {
  capabilities = ["create", "read", "list"]
}

# Transit encryption (no decryption or key mgmt)
path "transit/encrypt/ci-*" {
  capabilities = ["update"]
}


---

admin.hcl – Vault Admin

path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}


---

audit-read.hcl – Vault Auditor

path "sys/audit" {
  capabilities = ["read", "list"]
}
path "sys/internal/*" {
  capabilities = ["read", "list"]
}


---

🔐 LDAP Group to Policy Mapping

LDAP Group	Vault Role	Policies Assigned

app-devs	Developer	dev-read
lead-devs	Lead Developer	team-write
ci-implementers	Implementer	ci-infra-limited
vault-admins	Vault Admin	admin
vault-auditors	Vault Auditor	audit-read



---

⚙️ LDAP Auth Method Setup

vault auth enable ldap

vault write auth/ldap/config \
  url="ldaps://ldap.company.com" \
  binddn="cn=readonly,dc=company,dc=com" \
  bindpass="readonly-password" \
  userdn="ou=users,dc=company,dc=com" \
  groupdn="ou=groups,dc=company,dc=com" \
  groupfilter="(objectClass=group)" \
  groupattr="cn" \
  username_as_alias=true


---

🔗 Group Bindings

vault write auth/ldap/groups/app-devs policies="dev-read"
vault write auth/ldap/groups/lead-devs policies="team-write"
vault write auth/ldap/groups/ci-implementers policies="ci-infra-limited"
vault write auth/ldap/groups/vault-admins policies="admin"
vault write auth/ldap/groups/vault-auditors policies="audit-read"


---

✅ Best Practices

Path scoping: Ensure all policies restrict access to exact paths (e.g., ci-*).

Least privilege: Implementer has no access to broader secrets, only scoped automation needs.

Separation of duties: App teams, platform teams, and Vault teams are logically separated.

Use aliases: Enable username_as_alias=true for clean user mappings.

Review audit logs: Vault auditors can help track sensitive access patterns.



---

📘 This access model is modular, scalable, and secure — built for production Vault environments integrated with enterprise LDAP systems.

Let me know if you'd like a version that includes **namespaces** (Vault Enterprise) or **OIDC-based SSO group mappings** next.

