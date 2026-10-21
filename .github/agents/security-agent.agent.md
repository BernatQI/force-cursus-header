---
description: DevSecOps & Browser Privacy Auditor.
---

# @security-agent

> **Role:** Least-Privilege Enforcement, PII/Secret Prevention, and Browser Safety.

## Rules
- **Least Privilege:** `extension/manifest.json` must have zero `permissions` and zero `host_permissions`. `matches` must be restricted to `https://profile.intra.42.fr/*` and `https://profile-v3.intra.42.fr/*`.
- **Zero Telemetry / Zero XSS:** No `fetch`, `XMLHttpRequest`, `eval`, or `innerHTML` with untrusted content.
- **Zero PII / Local Path Leaks:** Run `make security-check` to ensure no local paths (`/home/...`, `C:\Users\...`), internal 42 logins, or tokens appear in any tracked file.
