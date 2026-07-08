# GOAL.md

Current objective:

> Deliver a runnable macOS menu bar StillPoint demo that detects monitored app drift, interrupts with a full-screen choice, supports Deep Work Lock, and summarizes the day with a Daily Attention Receipt.

This file is the project-level trace for Codex `/goal` mode and human review.
Update the status when a phase is genuinely implemented and verified.

## Phase 0: Product Definition

Status: Done

Goal:

- Define StillPoint's product philosophy, user problem, non-goals, and MVP scope.

Acceptance:

- `docs/product-spec.md` explains product principles, macOS Douyin scenario, Deep Work Lock, Daily Attention Receipt, technical principle, and expected effect.
- `docs/product-brief.md` gives a short positioning summary.

## Phase 1: Runnable macOS Shell

Status: Done

Goal:

- Create a SwiftPM macOS app that launches as a real app bundle and can be run from Codex.

Acceptance:

- `Package.swift` builds an executable named `StillPoint`.
- `script/build_and_run.sh` builds, bundles, launches, and supports `--verify`.
- `.codex/environments/environment.toml` exposes a Run action.
- `./script/build_and_run.sh --verify` succeeds.

## Phase 2: Drift Detection Core

Status: In progress

Goal:

- Detect when the user stays in a watched app long enough to trigger a check.

Acceptance:

- Foreground app monitoring uses `NSWorkspace.shared.frontmostApplication`.
- StillPoint ignores itself.
- Watched apps are configurable in the UI.
- Demo Mode uses a short threshold for fast presentation.
- Normal Mode uses a longer grace window to avoid interrupting valid use.
- Rule matching logic has unit tests via `./script/test.sh`.

## Phase 3: Intervention Overlay

Status: In progress

Goal:

- Interrupt drifting with a full-screen, calm, decisive choice surface.

Acceptance:

- Overlay appears above other apps.
- User can choose:
  - Looking something up
  - Intentional break
  - I drifted, close it
  - Lock this until focus ends
- Choosing a pass grants bounded time.
- Choosing close hides or exits the offending app where possible.
- Overlay behavior is verified with the simulator/demo button.

## Phase 4: Deep Work Lock

Status: In progress

Goal:

- Protect coding and agent-waiting sessions from quick feed escapes.

Acceptance:

- User can start and stop Deep Work Lock.
- Lock mode uses a stricter threshold.
- Lock state is visible in the UI.
- Lock events contribute to Daily Attention Receipt.

## Phase 5: Daily Attention Receipt

Status: In progress

Goal:

- Summarize the day without interrupting every app exit.

Acceptance:

- Receipt aggregates today's drift checks, purpose passes, closed drifts, locks, and protected time.
- Receipt appears inside the app, not as a per-exit popup.
- Receipt language is low-pressure and non-shaming.

## Phase 6: Polish and Reliability

Status: Done

Goal:

- Make the demo stable enough for presentation.

Acceptance:

- `./script/test.sh` passes.
- `./script/build_and_run.sh --verify` passes.
- Main flow can be demoed in under 60 seconds.
- README includes demo steps.
- GitHub `main` is pushed.

## Phase 6.5: Menu Bar Product Shape

Status: Done

Goal:

- Make StillPoint feel like a resident macOS utility rather than a generic dashboard app.

Acceptance:

- App launches as `LSUIElement=true` with no Dock icon.
- App can show a glass Control Center for demos.
- Closing Control Center leaves the menu bar agent running.
- Menu bar item exposes concise status text like `Still`, `Paused`, or `Lock 59s`.
- Menu bar popover exposes current state, progress, today's receipt preview, demo trigger, monitoring pause/resume, and Deep Work Lock.
- Control Center remains available on demand.
- `./script/test.sh` and `./script/build_and_run.sh --verify` pass.

## Phase 6.6: macOS UI Maturity Pass

Status: Done

Goal:

- Make StillPoint read as a mature macOS utility rather than an AI-generated card dashboard.

Acceptance:

- Control Center uses a native-feeling sidebar/detail/inspector structure.
- Sidebar rows stay compact and source-list-like.
- Dashboard emphasizes one live checkpoint surface, compact metrics, and a right inspector.
- Menu bar panel follows a CodexBar-like density pattern: top tabs, status sections, progress line, and concise command rows.
- Toolbar icons are semantic and do not duplicate system sidebar controls.
- `./script/test.sh` and `./script/build_and_run.sh --verify` pass.

## Phase 7: Android Migration Plan

Status: Not started

Goal:

- Explain how StillPoint moves from macOS prototype to Xiaomi 14 / Android.

Acceptance:

- Document Android architecture: UsageStatsManager, AccessibilityService, overlay.
- Document expected Xiaomi / HyperOS permission friction.
- Identify which macOS MVP concepts map directly and which need redesign.

## Current Demo Script

1. Open StillPoint.
2. Show the glass Control Center and the live frontmost app.
3. Keep Demo Mode on.
4. Click `Simulate drift`.
5. Show the full-screen intervention.
6. Choose `I drifted · Close it` or `Looking something up`.
7. Open `Daily Receipt` and show the aggregated result.
8. Close Control Center and show StillPoint continues in the menu bar.
9. Start `Work Lock` from the menu bar and explain the stricter threshold.
