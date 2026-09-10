# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please do not
open a public GitHub issue.

Instead, report the issue privately through GitHub's private vulnerability
reporting mechanism, if available.

When reporting a vulnerability, please include:

- A clear description of the issue
- The affected file, role, workflow, or configuration
- Steps to reproduce the issue
- The potential security impact
- Any relevant logs or proof-of-concept details

## Scope

This policy applies to the `vxlan-evpn-iac` repository and its associated
Ansible automation, configuration data, validation code, and CI/CD workflows.

## Secrets and Sensitive Data

This repository is intended to contain only sanitized, non-production
configuration.

Do not submit:

- Device credentials
- API keys or tokens
- Private keys
- Ansible Vault passwords
- Production management addresses or other sensitive infrastructure details
- GitHub Actions secrets

Local inventory and credential files are intentionally excluded from version
control.

## Disclosure

Please allow reasonable time for an issue to be investigated and addressed
before publicly disclosing details of a security vulnerability.

