# Windows Recovery Baseline Collector

## Purpose

Get-WindowsRecoveryBaseline.ps1 collects a small, read-only snapshot that can be attached to a troubleshooting ticket or compared with an approved baseline. It does not attempt to undo a specific optimizer's changes.

## Run It

~~~powershell
pwsh -NoProfile -File .\scripts\Get-WindowsRecoveryBaseline.ps1 -OutputPath .\reports\windows-recovery-baseline.json
~~~

Use -WhatIf to preview the report-writing action. Use -IncludeSystemFileScan only when a read-only sfc /verifyonly scan is appropriate for the investigation.

## Output

The JSON report includes:

- Windows version, build number, hardware model, and last boot time.
- Availability and newest timestamp of restore points when accessible.
- Status and configured start mode for common Windows support services.
- A snapshot of selected UAC policy values.
- Optional system-file verification output.

## Limits

- Access to restore points and service configuration can vary by Windows edition and privilege level.
- Captured registry values are evidence, not a recommendation to change them.
- The report may contain machine-identifying details. Store it with the ticket and do not commit it to a public repository.
