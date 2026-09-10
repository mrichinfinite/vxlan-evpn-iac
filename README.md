# VXLAN BGP EVPN Infrastructure as Code

Infrastructure as Code (IaC) project for building and validating a Cisco Nexus VXLAN BGP EVPN fabric using Ansible and Cisco Modeling Labs (CML).

This project uses GitHub as the single source of truth, Ansible for configuration implementation, GitHub Actions for automated CI validation, pull requests for human review, and separate deployment and validation workflows.

## Project Goals

- Build a reproducible VXLAN BGP EVPN fabric using Infrastructure as Code.
- Maintain GitHub as the authoritative source of desired state.
- Eliminate configuration drift and snowflake devices.
- Make infrastructure changes incremental, reviewable, testable, and reversible.
- Separate configuration implementation from validation.
- Automate repeatable network deployments with Ansible.
- Establish a disciplined NetDevOps development workflow.
- Demonstrate idempotent network automation.
- Provide an architecture that can be extended toward production-oriented use.

## Current Environment

The development environment is a Cisco Modeling Labs fabric consisting of:

- **S-1** — spine and BGP EVPN route reflector
- **L-1** — leaf and VXLAN VTEP
- **L-2** — leaf and VXLAN VTEP

The CML lab itself is managed separately from this repository. GitHub Actions performs repository and Ansible validation only; it does not create, start, or manage the CML lab.

## Architecture

The fabric uses:

- OSPF for the IP underlay
- PIM BiDir for multicast transport
- BGP EVPN for the overlay control plane
- VXLAN for the overlay data plane
- Loopback0 for underlay and BGP identity
- Loopback1 for the NVE/VTEP source
- Symmetric IRB for Layer 3 VXLAN forwarding
- Anycast gateway
- Tenant VRF with an L3VNI
- BGP route reflection on the spine
- VLAN-based Layer 2 VNIs
- A shared L3VNI for tenant routing

See [docs/architecture.md](docs/architecture.md) for the detailed design.

## Configuration Sections

The implementation is intentionally divided into independent configuration sections:

| Section | Purpose |
|---|---|
| 00 | Required NX-OS features |
| 01 | Underlay and EVPN control plane |
| 02 | L2 VXLAN/EVPN overlay |
| 03 | L3 VXLAN/EVPN overlay |
| 04 | vPC — reserved for future implementation |
| 05 | Multisite — reserved for future implementation |
| 06 | Endpoint attachments |

The section structure is reflected consistently across Ansible roles, deployment playbooks, and validation playbooks.

## Source of Truth

Desired-state information is maintained under `data/`.

Key files include:

| File | Purpose |
|---|---|
| `data/standards.yml` | Engineering and configuration standards |
| `data/fabric.yml` | Fabric-level parameters |
| `data/devices.yml` | Device-specific desired state |
| `data/topology.yml` | Physical and logical topology |
| `data/overlay.yml` | VXLAN/EVPN overlay parameters |
| `data/policies.yml` | Network policy definitions |

Ansible roles implement the desired state.

Architectural and policy decisions remain in the appropriate data and standards files rather than being hidden inside individual tasks.

## Repository Structure

```text
vxlan-evpn-iac/
├── .github/
│   └── workflows/
│       └── ci.yml
├── data/
│   ├── standards.yml
│   ├── fabric.yml
│   ├── devices.yml
│   ├── topology.yml
│   ├── overlay.yml
│   └── policies.yml
├── docs/
│   ├── architecture.md
│   ├── standards.md
│   └── change-governance.md
├── inventory/
│   ├── hosts.example.yml
│   └── group_vars/
│       └── all/
│           └── vault.example.yml
├── playbooks/
│   ├── deploy_features.yml
│   ├── deploy_underlay.yml
│   ├── deploy_overlay_l2.yml
│   ├── deploy_overlay_l3.yml
│   └── deploy_endpoints.yml
├── roles/
│   ├── 00_features/
│   ├── 01_underlay/
│   ├── 02_overlay_l2/
│   ├── 03_overlay_l3/
│   ├── 04_vpc/
│   │   └── tasks/
│   │       └── .gitkeep
│   ├── 05_multisite/
│   │   └── tasks/
│   │       └── .gitkeep
│   └── 06_endpoints/
├── tests/
│   └── validation/
│       ├── validate_features.yml
│       ├── validate_underlay.yml
│       ├── validate_overlay_l2.yaml
│       ├── validate_overlay_l3.yml
│       └── validate_endpoints.yml
├── .gitignore
├── ansible.cfg
├── populate_ssot.sh
├── README.md
├── requirements.txt
└── requirements.yml
