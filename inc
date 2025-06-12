{panel:title=🔐 Overview | borderStyle=solid|borderColor=#ccc|titleBGColor=#f0f0f0|bgColor=#ffffff}
To enable secure secret retrieval at **application startup and runtime**, your application must integrate with **HashiCorp Vault** using the **Vault Agent Sidecar Injector**.

This document outlines the onboarding process and requirements for application teams to leverage Vault for secure secret injection.
{panel}

{panel:title=📌 Prerequisites | borderStyle=solid|borderColor=#ccc|titleBGColor=#EAF5FF|bgColor=#ffffff}
Before onboarding to Vault can begin, your application must be onboarded to the **OpenShift Container Platform (OCP)**.

Please provide the following details to the Vault team:

- ✅ OCP **Project/Namespace**
- ✅ Associated **Kubernetes Service Account**

> 🧑‍💼 **Action Required:** Coordinate with the OCP team to create and verify these components.
{panel}

{panel:title=🚀 Vault Onboarding Process | borderStyle=solid|borderColor=#ccc|titleBGColor=#FFF4E5|bgColor=#ffffff}
Once the required OCP details are provided, the Vault team will:

1. Create a Vault **role** mapped to your Kubernetes Service Account.
2. Attach **Vault policies** to control access to secrets.
3. Configure **Vault Injector annotations** for your deployment, enabling automatic sidecar injection.

> 📄 Sample injector annotations and templates will be provided by the Vault team upon request.
{panel}

{panel:title=🔁 Vault Injector Workflow | borderStyle=solid|borderColor=#ccc|titleBGColor=#E9FFE5|bgColor=#ffffff}
The Vault Agent Sidecar enables the following:

- A sidecar container is **automatically injected** into your pod.
- It **authenticates with Vault** using the service account JWT token.
- Secrets are **retrieved securely** from Vault and written to a shared memory volume or environment.
- Secrets can be **dynamically refreshed** during runtime if supported.

> 🔐 This approach ensures that your secrets are never hardcoded or stored insecurely.
{panel}

{panel:title=✅ Application Team Checklist | borderStyle=solid|borderColor=#ccc|titleBGColor=#F0F0FF|bgColor=#ffffff}
1. Provide the following to the Vault team:
   - OCP Namespace / Project
   - Kubernetes Service Account name
   - Secret paths and purpose (e.g., DB creds, API tokens)

2. Add the required Vault annotations in your deployment YAML.

3. Validate that the Vault Agent has permission to retrieve the defined secrets.

> 💡 Vault team will assist with the correct policy, annotation, and injector setup.
{panel}

{panel:title=🛡️ Best Practices | borderStyle=solid|borderColor=#ccc|titleBGColor=#FFF2F2|bgColor=#ffffff}
- ❌ Do not hardcode secrets in application configs.
- ✅ Use Vault Agent templates for writing secrets to environment or file.
- 🔄 Enable secret rotation and renewal where applicable.
- 🧾 Keep namespace/service account consistent and documented.

{panel}

{panel:title=📞 Contact & Support | borderStyle=solid|borderColor=#ccc|titleBGColor=#F9F9F9|bgColor=#ffffff}
- 🛠️ **Vault Team**: [vault-support@yourdomain.com|mailto:vault-support@yourdomain.com]  
- 🧑‍💻 **OCP Platform Team**: [ocp-support@yourdomain.com|mailto:ocp-support@yourdomain.com]

> Reach out for onboarding help, YAML samples, or troubleshooting.
{panel}