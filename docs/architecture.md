# Architecture

## Overview

This project implements a Cisco Nexus VXLAN BGP EVPN fabric in Cisco Modeling Labs (CML).

The current development topology consists of one spine and two leaves:

```text
                 S-1
          Spine / RR
          10.0.0.11
           /       \
          /         \
       L-1           L-2
      VTEP           VTEP
  10.0.0.1        10.0.0.2