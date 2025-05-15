Sure! Here's the same documentation in a README.md format suitable for GitHub or other Markdown-based tools:

# Vault Agent Injector - End User Guide

This guide explains how to integrate HashiCorp Vault secrets into your Kubernetes applications using the **Vault Agent Injector**. It includes required annotations, deployment patterns, and best practices.

---

## Overview

The Vault Agent Injector uses a Kubernetes Mutating Admission Webhook to automatically inject secrets into pods at runtime via Vault Agent. Secrets can be injected as files or environment variables.

---

## Prerequisites

- A running Kubernetes cluster.
- Vault Agent Injector deployed in the cluster.
- Vault server accessible from the cluster.
- Kubernetes auth method enabled in Vault.
- Vault role and policies configured for your application.
- ServiceAccount in Kubernetes with appropriate annotations.

---

## Injector Workflow

1. Annotated pod/deployment is created.
2. Injector mutates the pod:
   - Adds Vault Agent sidecar.
   - Adds shared volumes for secrets.
   - Configures secret paths and templates.
3. Vault Agent authenticates using Kubernetes ServiceAccount JWT.
4. Secrets are retrieved from Vault and rendered into files inside the container.

---

## Required Annotations

| Annotation | Description |
|------------|-------------|
| `vault.hashicorp.com/agent-inject` | Set to `true` to enable injection. |
| `vault.hashicorp.com/role` | Vault role for authentication. |
| `vault.hashicorp.com/agent-inject-secret-<file>` | Vault path of the secret. `<file>` is the output filename. |
| `vault.hashicorp.com/agent-inject-template-<file>` _(optional)_ | Go template to format the secret. |
| `vault.hashicorp.com/agent-inject-file-<file>` _(optional)_ | Custom filename for the injected secret. |
| `vault.hashicorp.com/agent-inject-token` _(optional)_ | Set to `true` to inject the Vault token. |
| `vault.hashicorp.com/namespace` _(Vault Enterprise)_ | Vault namespace for the request. |

---

## Example Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "example-app-role"
        vault.hashicorp.com/agent-inject-secret-config: "secret/data/apps/example/config"
        vault.hashicorp.com/agent-inject-template-config: |
          {{- with secret "secret/data/apps/example/config" -}}
          export DB_USERNAME={{ .Data.data.username }}
          export DB_PASSWORD={{ .Data.data.password }}
          {{- end }}
        vault.hashicorp.com/agent-inject-file-config: "app.env"
      labels:
        app: example
    spec:
      serviceAccountName: example-app-sa
      containers:
      - name: app
        image: busybox
        command: ["/bin/sh"]
        args: ["-c", "source /vault/secrets/app.env && env && sleep 3600"]


---

Injected File Location

Injected secrets are written to:

/vault/secrets/<file>

In the example above:

/vault/secrets/app.env


---

Best Practices

Use file-based secret injection over environment variables.

Define strict Vault policies for minimal access.

Use dedicated Vault roles per application.

Enable auto-renew and short-lived tokens.

Audit Vault Agent logs in /vault/logs/.



---

Troubleshooting

Problem	Solution

Secrets not injected	Check annotations and Vault role/policy bindings.
Pod stuck in Init	Review Vault Agent logs in the sidecar container.
Vault 403 errors	Validate Vault role and policies.
Namespace errors	Set correct vault.hashicorp.com/namespace if using Vault Enterprise.



---

Useful Links

Vault Kubernetes Injector Docs

Vault Kubernetes Auth

Vault Policy Reference



---

Let me know if you'd like this saved to a downloadable `.md` file.

