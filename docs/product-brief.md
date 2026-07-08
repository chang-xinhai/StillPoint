# StillPoint Product Brief

## Positioning

StillPoint is not another strict app blocker. It is an intention checkpoint:
when the user drifts into a monitored app or site for too long, StillPoint
occupies the screen and asks for a reason to continue.

## Competitor Reference

- one sec: a short intervention before opening distracting apps.
- ScreenZen: delays, app goals, and interruption-based screen time control.
- Opal: polished focus sessions and cross-platform screen time control.
- ClearSpace: reduces addictive access while preserving useful phone behavior.

## Differentiation

StillPoint focuses on protecting boredom and restoring agency. The product
should feel less like punishment and more like a quiet checkpoint between
impulse and attention.

## macOS MVP

- Foreground app monitoring with configurable watched apps.
- Browser URL or title-based monitoring where feasible.
- Sustained-use timer.
- Full-screen interruption overlay.
- Intent prompt before continuing.
- Local session log.
- Demo mode with short thresholds.

## Android Migration Notes

The Android version should use UsageStatsManager for usage state, an
AccessibilityService for foreground context, and a system overlay for the
intervention surface. Xiaomi / HyperOS will likely require manual permissions
for overlay, accessibility, battery, and background behavior.

