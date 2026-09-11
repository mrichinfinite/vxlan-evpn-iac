# Engineering Standards

## Purpose

This document describes the engineering standards governing the VXLAN BGP EVPN IaC project.

The machine-readable implementation of these standards is maintained in:

`data/standards.yml`

The YAML file is the authoritative representation consumed by automation.

## Infrastructure as Code

The project follows these principles:

- GitHub is the single source of truth.
- Desired state is represented as code and structured data.
- Network configuration must be reproducible.
- Manual device configuration must not become the permanent implementation.
- Configuration drift should be detectable.
- Infrastructure changes must be reviewable before deployment.

## Deployment Standards

Deployments must be:

- incremental
- targeted
- reproducible
- validated

Big-bang deployment is prohibited.

Changes should be broken into logical sections so that each stage can be independently tested and rolled back.

## Change Control

The project requires:

- feature branches
- pull requests
- CI validation
- human review
- controlled deployment
- post-deployment validation
- rollback capability

See `change-governance.md` for the complete workflow.

## Feature Standards

Required common fabric features include:

- OSPF
- PIM
- BGP
- NV Overlay

Required leaf features include:

- interface-vlan
- vn-segment-vlan-based
- fabric forwarding

EVPN must be enabled on fabric devices.

Optional capabilities such as vPC and LACP remain disabled unless explicitly enabled through the source of truth.

## Underlay Standards

The default underlay is:

| Function | Standard |
|---|---|
| IGP | OSPF |
| Multicast | BIDIR-PIM |
| OSPF Area | 0 |
| Fabric MTU | 9216 |

Loopback0 is used for underlay routing identity.

## Loopback Standards

### Loopback0

Loopback0 provides:

- OSPF router ID
- BGP router ID
- Underlay identity

### Loopback1

Loopback1 provides:

- NVE source
- VTEP identity

The project intentionally separates these responsibilities.

## Overlay Standards

The overlay uses:

- EVPN control plane
- VXLAN data plane
- L2VNIs for Layer 2 segments
- L3VNI for Layer 3 segments / tenant routing
- Anycast gateway
- Symmetric IRB by default

Any deviation from symmetric IRB requires explicit design approval.

## Multicast Standards

BIDIR-PIM is the standard multicast mode.

The current lab uses a single RP.

Phantom RP is an optional future capability for RP redundancy but it is not enabled by default.

## vPC Standards

When vPC is required, the project standard is:

**vPC Fabric Peering**

This uses the VXLAN fabric for the virtual peer-link rather than requiring a dedicated physical peer-link.

Platform-specific requirements must be validated before enabling vPC capabilities.

vPC is optional and disabled by default.

## Multi-Site Standards

Multi-site functionality is optional.

When required, the architecture will use designated Border Gateway (BGW) leaves and the appropriate EVPN multi-site controls.

Multi-site configuration must not be introduced into the current single-site lab unless explicitly required by a future design change.

## Role Standards

Ansible roles implement the desired state.

Roles should:

- consume structured desired-state data
- remain modular
- avoid embedding architectural policy unnecessarily
- be idempotent
- implement only their intended responsibility

Configuration implementation and validation are separate concerns.

## Validation Standards

Validation must independently verify actual device state.

A successful Ansible configuration task does not, by itself, constitute successful network validation.

Validation should confirm:

- intended configuration exists
- intended operational state exists
- no unexpected changes occurred
- standards remain satisfied

## Security Standards

- Secrets must never be committed in plaintext.
- Ansible Vault is used for encrypted repository secrets where appropriate.
- Local Vault passwords remain outside the repository.
- CI/CD credentials should be supplied through GitHub Secrets.
- Self-hosted runners must be treated as privileged infrastructure.
- Public repositories must not expose an inadequately isolated persistent self-hosted runner.

## Rollback Standards

Every infrastructure change must have a practical rollback path.

Changes should be small enough that a known-good Git revision can serve as a clear recovery reference.

A failed deployment or failed validation must be resolved before proceeding to the next change.

## Governing Principle

> **Automate consistently, change incrementally, validate independently, and never allow an unreviewed configuration change to become the new normal.**
