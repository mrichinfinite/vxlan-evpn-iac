#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# VXLAN BGP EVPN IaC
# SSOT DATA / INVENTORY BOOTSTRAP
#
# This script populates the repository's declarative SSOT.
#
# The generated files are consumed by Ansible roles.
# Do not configure production/lab devices directly from this
# script.
#
# Repository structure and group names must remain compatible
# with the Ansible automation.
# ============================================================


# ============================================================
# DIRECTORIES
# ============================================================

mkdir -p data
mkdir -p inventory/group_vars/all


# ============================================================
# STANDARDS
# ============================================================

cat > data/standards.yml <<'EOF'
---
standards:

  ssot:
    repository_is_authoritative: true
    direct_device_configuration_allowed: false

  governance:
    pull_request_required: true
    human_review_required: true
    approval_required: true

  deployment:

    strategy: incremental

    big_bang_deployments_allowed: false

    requirements:
      - targeted_changes
      - pre_deployment_validation
      - post_deployment_validation
      - rollback_capability

    progression:
      - deploy_small_change
      - validate_change
      - proceed_to_next_stage

  naming:

    devices:
      spine_prefix: "S-"
      leaf_prefix: "L-"
      border_gateway_prefix: "B-"
      host_prefix: "H-"

    interfaces:

      loopback0:
        required_purpose:
          - underlay_routing_identity
          - ospf_router_id
          - bgp_router_id
          - bgp_update_source

      loopback1:
        required_purpose:
          - vtep_source

      loopback2_plus:
        allowed_purposes:
          - multicast_rp
          - multisite_bgw_source
          - infrastructure_service

  features:

    common:
      required:
        - ospf
        - pim
        - bgp
        - nv overlay

    evpn:
      enabled: true
      command: nv overlay evpn

    spine:
      required:
        - ospf
        - pim
        - bgp
        - nv overlay

    leaf:
      required:
        - vn-segment-vlan-based
        - fabric forwarding
        - interface-vlan

    optional:
      vpc: false
      lacp: false

  underlay:

    routing_protocol:
      required: ospf

      allowed:
        - ospf

      disallowed:
        - isis
        - eigrp

    addressing:

      fabric_links:
        required: ip_unnumbered

    mtu:

      fabric_links:
        required: 9216

    ospf:

      process: UNDERLAY

      area:
        required: 0.0.0.0

  multicast:

    required: true

    mode:
      required: pim_bidir

    rp_redundancy:

      current_design: single_rp

      optional_designs:
        - phantom_rp

  bgp_evpn:

    required: true

    deployment_model:
      required: ibgp

    address_family:
      required: l2vpn_evpn

    communities:
      required:
        - standard
        - extended

    route_reflectors:
      required: true

      allowed_roles:
        - spine

  overlay:

    vtep:

      source_interface:
        required: loopback1

    l2:

      vlan_to_vni_mapping:
        required: true

      evpn_vni:
        required: true

    l3:

      routing_model:
        default: symmetric_irb

      alternative_design:
        allowed_only_with_documented_exception: true

      l3vni:
        required:
          - vrf_vni
          - vrf_shared_vlan
          - vn_segment_mapping
          - l3vni_svi
          - ip_forward
          - nve_associate_vrf

    anycast_gateway:
      required:
        - common_gateway_mac
        - anycast_gateway_svi

  vpc:

    optional: true

    preferred_architecture:
      - fabric_peering

    physical_peer_link:
      disallowed: true

    virtual_peer_link:
      required_when_enabled: true

    peer_keepalive:
      required_when_enabled: true

  multisite:

    optional: true

    required_when_enabled:
      - border_gateway
      - site_id
      - multisite_source_loopback
      - bgw_tracking
      - external_evpn_peering

    dci:

      mtu:
        required: 9216

  configuration_workflow:

    - section: "00_features"

    - section: "01_underlay"

    - section: "02_overlay_l2"

    - section: "03_overlay_l3"

    - section: "04_vpc"
      optional: true

    - section: "05_multisite"
      optional: true
EOF


# ============================================================
# FABRIC
# ============================================================

cat > data/fabric.yml <<'EOF'
---
fabric:

  name: vxlan-evpn-lab

  platform:
    vendor: cisco
    os: nxos
    version: "10.6(2)"
    hardware: "Nexus9000 C9300v"

  capabilities:

    vpc:
      enabled: false

    multisite:
      enabled: false

    arp_suppression:
      enabled: false

    phantom_rp:
      enabled: false

  addressing:

    underlay_loopbacks:
      prefix_length: 32

    vtep_loopbacks:
      prefix_length: 32

  underlay:

    routing_protocol: ospf

    ospf:
      process: UNDERLAY
      area: 0.0.0.0

    mtu: 9216

    addressing:
      fabric_links: ip_unnumbered
      source_loopback: loopback0

  multicast:

    mode: pim_bidir

    rp:
      type: single
      address: 10.1.1.11
      group_list: 224.0.0.0/4

    phantom_rp:
      supported: true
      enabled: false

  bgp:

    asn: 65001

    deployment_model: ibgp

    evpn_address_family: l2vpn_evpn

    route_reflection:
      enabled: true
      route_reflector_role: spine

  overlay:

    vtep_source_interface: loopback1

    host_reachability_protocol: bgp

    routing_model: symmetric_irb

    replication:
      mode: multicast

    anycast_gateway_mac: "0000.1234.5678"
EOF


# ============================================================
# DEVICES
# ============================================================

cat > data/devices.yml <<'EOF'
---
devices:

  S-1:

    role: spine

    loopbacks:

      loopback0:
        address: 10.0.0.11/32
        ospf: true
        pim: true

      loopback2:
        address: 10.1.1.11/32
        ospf: true
        pim: true
        purpose: multicast_rp

    ospf:
      router_id: 10.0.0.11

    bgp:
      router_id: 10.0.0.11
      update_source: loopback0
      route_reflector: true

    features:
      - ospf
      - pim
      - bgp
      - nv overlay


  L-1:

    role: leaf

    loopbacks:

      loopback0:
        address: 10.0.0.1/32
        ospf: true
        pim: true

      loopback1:
        address: 10.0.1.1/32
        ospf: true
        pim: true
        purpose: vtep_source

    ospf:
      router_id: 10.0.0.1

    bgp:
      router_id: 10.0.0.1
      update_source: loopback0

    features:
      - ospf
      - pim
      - bgp
      - nv overlay
      - vn-segment-vlan-based
      - fabric forwarding
      - interface-vlan


  L-2:

    role: leaf

    loopbacks:

      loopback0:
        address: 10.0.0.2/32
        ospf: true
        pim: true

      loopback1:
        address: 10.0.1.2/32
        ospf: true
        pim: true
        purpose: vtep_source

    ospf:
      router_id: 10.0.0.2

    bgp:
      router_id: 10.0.0.2
      update_source: loopback0

    features:
      - ospf
      - pim
      - bgp
      - nv overlay
      - vn-segment-vlan-based
      - fabric forwarding
      - interface-vlan
EOF


# ============================================================
# TOPOLOGY
# ============================================================

cat > data/topology.yml <<'EOF'
---
topology:

  fabric_links:

    - description: "S-1 to L-1 underlay fabric link"
      local_device: S-1
      local_interface: Ethernet1/1
      remote_device: L-1
      remote_interface: Ethernet1/1

    - description: "S-1 to L-2 underlay fabric link"
      local_device: S-1
      local_interface: Ethernet1/2
      remote_device: L-2
      remote_interface: Ethernet1/2


  host_links:

    - description: "H-1 connection to L-1 access VLAN 10"
      device: L-1
      interface: Ethernet1/5
      host: H-1
      vlan: 10

    - description: "H-2 connection to L-2 access VLAN 20"
      device: L-2
      interface: Ethernet1/5
      host: H-2
      vlan: 20

    - description: "H-3 connection to L-2 access VLAN 10"
      device: L-2
      interface: Ethernet1/6
      host: H-3
      vlan: 10
EOF


# ============================================================
# OVERLAY
# ============================================================

cat > data/overlay.yml <<'EOF'
---
overlay:

  tenants:

    TENANT:

      l3vni:
        vlan: 30
        vni: 100030

      vrf:
        rd: auto

        address_families:

          ipv4_unicast:

            route_target:
              ipv4: auto
              evpn: auto

      vlans:

        10:

          name: TENANT_VLAN_10
          vni: 100010
          type: l2

          multicast_group: 239.0.0.10

          evpn:

            rd: auto

            route_target:
              import: auto
              export: auto

          svi:

            enabled: true

            anycast_gateway: true

            address: 192.168.10.254/24

            route_tag: 12345

            deployed_on:
              - L-1
              - L-2


        20:

          name: TENANT_VLAN_20
          vni: 100020
          type: l2

          multicast_group: 239.0.0.20

          evpn:

            rd: auto

            route_target:
              import: auto
              export: auto

          svi:

            enabled: true

            anycast_gateway: true

            address: 192.168.20.254/24

            route_tag: 12345

            deployed_on:
              - L-2


        30:

          name: TENANT_L3VNI
          vni: 100030
          type: l3

          multicast_group: 239.0.0.30

          svi:

            enabled: true

            vrf: TENANT

            ip_forward: true

            no_ip_redirects: true

            deployed_on:
              - L-1
              - L-2

      deployed_on:
        - L-1
        - L-2
EOF


# ============================================================
# POLICIES
# ============================================================

cat > data/policies.yml <<'EOF'
---
policies:

  route_maps:

    TAGGED:

      description: >
        Matches directly connected SVI routes carrying the required route tag
        for redistribution into the tenant BGP address family.

      sequence: 10

      action: permit

      match:

        tag: 12345


  bgp:

    vrf_redistribution:

      TENANT:

        address_family: ipv4_unicast

        redistribute:

          source: direct

          route_map: TAGGED
EOF


# ============================================================
# ANSIBLE INVENTORY
#
# IMPORTANT:
# Keep these group names compatible with the Ansible roles:
#
#   fabric  -> all fabric devices
#   spines  -> spine devices
#   leaves  -> leaf devices
#
# Do not rename these groups without updating the automation.
# ============================================================

cat > inventory/hosts.yml <<'EOF'
---
all:
  vars:
    ansible_connection: ansible.netcommon.network_cli
    ansible_network_os: cisco.nxos.nxos
    ansible_port: 22

  children:
    fabric:
      children:
        spines:
          hosts:
            S-1:
              ansible_host: 192.168.239.30

        leaves:
          hosts:
            L-1:
              ansible_host: 192.168.239.31
            L-2:
              ansible_host: 192.168.239.32
EOF


# ============================================================
# COMPLETION
# ============================================================

echo "SSOT data files and inventory created successfully."
