# VXLAN BGP EVPN Infrastructure as Code

Infrastructure as Code (IaC) development project for a Cisco Nexus VXLAN BGP EVPN fabric running in Cisco Modeling Labs (CML).

This project uses Ansible to implement network configuration from a Git-managed desired state, with GitHub as the single source of truth (SSOT), GitHub Actions for automated CI/CD validation, pull requests for human review, and separate deployment, validation, and compliance workflows.

## Project Goals

- Build a reproducible VXLAN BGP EVPN fabric using Infrastructure as Code.
- Maintain GitHub as the authoritative source of truth for desired state.
- Eliminate configuration drift and snowflake devices.
- Make infrastructure changes incremental, reviewable, testable, and reversible.
- Separate configuration implementation from validation and compliance.
- Automate repeatable network deployments with Ansible.
- Establish a disciplined NetDevOps development workflow.
- Build toward a reusable architecture suitable for future production-oriented use.

## Current Environment

The current development environment is a Cisco Modeling Labs fabric consisting of:

- **S-1** — spine and BGP EVPN route reflector
- **L-1** — leaf and VXLAN VTEP
- **L-2** — leaf and VXLAN VTEP

The GitHub Actions pipeline operates against the existing CML environment. GitHub Actions does not create, start, or manage the CML lab itself.

## Architecture

The fabric uses:

- OSPF for the IP underlay
- PIM BiDir for multicast transport
- BGP EVPN for the control plane
- VXLAN for the overlay data plane
- Loopback0 for OSPF and BGP identity
- Loopback1 for the NVE/VTEP source
- Symmetric IRB as the default L3 forwarding model
- Anycast gateway
- Tenant VRF with an L3VNI

See [`docs/architecture.md`](docs/architecture.md) for the detailed architecture.

## Source of Truth

Desired-state information is maintained under `data/`.

Key files include:

| File | Purpose |
|---|---|
| `data/standards.yml` | Engineering and change-control standards |
| `data/fabric.yml` | Fabric-level parameters |
| `data/devices.yml` | Device-specific desired state |
| `data/topology.yml` | Physical and logical topology |
| `data/overlay.yml` | VXLAN/EVPN overlay parameters |
| `data/policies.yml` | Network policy definitions |

Ansible roles implement the desired state. Architectural policy remains in the appropriate data and standards files rather than being hidden inside individual tasks.

## Repository Structure

```text
vxlan-evpn-iac/
├── ansible.cfg
├── requirements.txt
├── requirements.yml
├── .gitignore
├── README.md
├── populate_ssot.sh
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
│       └── all/
│           └── vault.yml
├── data/
│   ├── standards.yml
│   ├── fabric.yml
│   ├── devices.yml
│   ├── topology.yml
│   ├── overlay.yml
│   └── policies.yml
├── playbooks/
│   ├── deploy.yml
│   ├── deploy_features.yml
│   ├── validate.yml
│   └── compliance.yml
├── roles/
│   ├── 00_features/
│   ├── 01_underlay/
│   ├── 02_overlay_l2/
│   ├── 03_overlay_l3/
│   ├── 04_vpc/
│   └── 05_multisite/
├── tests/
│   ├── validation/
│   └── compliance/
├── docs/
│   ├── architecture.md
│   ├── standards.md
│   └── change-governance.md
└── .github/
    └── workflows/
        └── ci.yml