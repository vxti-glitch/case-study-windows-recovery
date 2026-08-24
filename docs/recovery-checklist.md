# Windows Recovery Checklist

## Before Changing the System

- Record exact symptoms, error messages, and the last known change.
- Confirm whether the device can boot normally and in Safe Mode.
- Verify backups or another recovery path.
- Create a restore point when the system state permits it.
- Export any registry key before editing it.
- Record current service startup settings before changing them.

## Diagnostic Order

1. Reproduce the symptom.
2. Check Event Viewer for related errors.
3. Review installed software and recent changes.
4. Inspect relevant services and policy settings.
5. Use `sfc /verifyonly` or DISM scan commands when system-file damage is suspected.
6. Compare configuration with authoritative Microsoft documentation.
7. Test one reversible change at a time.

## Validation

- Repeat the original reproduction steps.
- Restart and test again.
- Confirm unrelated Windows features still work.
- Capture final ticket notes and any approved exceptions.

## Escalate When

- The device cannot boot reliably.
- BitLocker recovery information is unavailable.
- System files or permissions remain damaged.
- The required change is not reversible.
- Business data may be at risk.
