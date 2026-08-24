# Case Study: Windows Recovery After an Optimizer Conflict

[![PowerShell validation](https://github.com/vxti-glitch/case-study-windows-recovery/actions/workflows/powershell-validation.yml/badge.svg)](https://github.com/vxti-glitch/case-study-windows-recovery/actions/workflows/powershell-validation.yml)
![Case study](https://img.shields.io/badge/Format-sanitized_case_study-0F766E)
![Focus](https://img.shields.io/badge/Focus-Windows_support-2563EB)

A sanitized reconstruction of a Windows recovery incident in which a third-party optimization utility changed system configuration and left core features partially unavailable.

No real usernames, device names, registry exports, screenshots, or product identifiers are included.

## Ticket Summary

| Field | Detail |
| --- | --- |
| Ticket type | Software conflict and operating-system impairment |
| Impact | Settings and selected applications were unavailable |
| Access | Local administrator |
| Constraint | Preserve user data and avoid a full reinstall |
| Resolution time | Approximately 2 to 3 hours |
| Outcome | Functionality restored with no wipe or reported data loss |

## Incident Flow

```mermaid
flowchart LR
    A[Record affected features] --> B[Identify likely change surfaces]
    B --> C[Inspect registry and permissions]
    C --> D[Compare against documented defaults]
    D --> E[Revert one change]
    E --> F[Test affected feature]
    F -->|Still broken| E
    F -->|Restored| G[Validate and document]
```

## Problem

After an optimization utility was run, the computer remained bootable but some Windows controls and applications stopped working. The main technical goal was to isolate the configuration changes and recover the system without destroying user data.

## Actions Taken

1. Recorded the broken and working features to establish a failure baseline.
2. Researched the common change surfaces for this category of utility, including registry policy values, service startup configuration, and system permissions.
3. Inspected relevant registry areas and compared changed values with documented Windows defaults.
4. Checked system-directory permissions to determine whether access control changes were contributing to the failures.
5. Reverted candidate configuration changes individually and tested the affected feature after each change.
6. Repeated validation after the final recovery to confirm the original symptoms did not return.

## Resolution

The affected configuration values were restored to Windows defaults. The unavailable features returned, the system remained bootable, and a reinstall was not required.

## Verification

- Confirmed each originally reported feature opened normally.
- Restarted the computer and repeated the checks.
- Confirmed user files and applications remained present.
- Documented preventive controls for future system-tuning changes.

## Evidence Limitations

This case study was reconstructed after the incident. The original registry paths, event logs, and screenshots were not retained, so this repository does not claim a reproducible fix for a specific optimizer. It documents the troubleshooting method and the verified outcome.

## Portfolio Artifacts

- [Sanitized ticket record](docs/sanitized-ticket.md)
- [Windows recovery checklist](docs/recovery-checklist.md)

## Companion Tool

The case study now includes [Get-WindowsRecoveryBaseline.ps1](scripts/Get-WindowsRecoveryBaseline.ps1), a read-only PowerShell collector for documenting a Windows recovery investigation. It captures operating-system details, selected service states, recovery-point availability, and a small set of UAC policy values. It does not edit the registry, services, or system files.

~~~powershell
pwsh -NoProfile -File .\scripts\Get-WindowsRecoveryBaseline.ps1 -OutputPath .\reports\windows-recovery-baseline.json
~~~

Add -IncludeSystemFileScan to run sfc /verifyonly. That scan is read-only but may take time. See the [tool usage guide](docs/tool-usage.md) for output fields and operational limits.

## Skills Demonstrated

Windows troubleshooting, registry awareness, root-cause isolation, change control, rollback planning, verification, and ticket documentation.

> Registry edits can make a system unbootable. Export affected keys, create a recovery path, and verify changes against authoritative documentation before modifying production systems.
