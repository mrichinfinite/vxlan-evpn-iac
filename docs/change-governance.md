# Change Governance

## Purpose

This document defines the standard workflow for making changes to the VXLAN BGP EVPN Infrastructure as Code project.

The goal is to make every infrastructure change:

- incremental
- reviewable
- testable
- reproducible
- safely deployable
- independently verifiable
- recoverable

GitHub is the single source of truth for the desired state.

## Standard Workflow

```text
Identify change
      ↓
Create feature branch
      ↓
Modify SSOT / automation
      ↓
Local validation
      ↓
Commit
      ↓
Push feature branch
      ↓
GitHub Actions CI
      ↓
Pull Request
      ↓
Human review
      ↓
Merge to main
      ↓
Controlled deployment
      ↓
Post-deployment validation
      ↓
Known-good checkpoint
      ↓
Next incremental change
