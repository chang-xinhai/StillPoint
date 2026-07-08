# AGENTS.md

StillPoint agent working rules.

## Project

**StillPoint** is a macOS-first attention intervention prototype.

Core idea:

> Do not block every use. Detect when purposeful use drifts into unconscious feed consumption, then create a calm but firm pause.

MVP platform: macOS SwiftUI / AppKit via Swift Package Manager.  
Next platform: Android, using usage stats, accessibility, and overlay APIs.

## Product Rules

- Do not turn StillPoint into a generic productivity dashboard.
- Do not shame the user. The product tone is calm, direct, and humane.
- Do not monitor broad work tools by default: VSCode, Cursor, Terminal, Lark, Obsidian, Notion, Chrome, Safari.
- Only watch explicitly enabled high-risk apps or feed domains.
- Attention Receipt is daily, not shown after every app exit.
- Deep Work Lock should protect coding and agent-waiting sessions without breaking normal work.

## Engineering Rules

- Prefer the existing SwiftPM macOS app structure:
  - `Sources/StillPoint/App`
  - `Sources/StillPoint/Models`
  - `Sources/StillPoint/Stores`
  - `Sources/StillPoint/Services`
  - `Sources/StillPoint/Views`
  - `Sources/StillPoint/Support`
- Keep files focused. Do not put models, services, and all views into one giant file.
- Use SwiftUI for app UI and AppKit only where macOS system behavior is needed, such as foreground app detection or overlay windows.
- Keep user data local by default. Do not add network calls unless a task explicitly requires them.
- Avoid secrets in code, docs, commits, logs, or screenshots.

## UI Rules

- StillPoint should feel small, calm, and premium, closer to ScreenZen / Opal than a generic admin dashboard.
- Prefer native macOS sidebar-detail structure, system colors, semantic foreground styles, subtle borders, and light shadows.
- Keep cards sparse and purposeful. Do not nest cards or fill the app with heavy gray panels.
- Use clear icon buttons or icon-led controls for primary actions; add help text where the action is not obvious.
- Intervention UI should feel like a quiet system checkpoint, not an alarm, punishment screen, or marketing page.
- Avoid oversized hero typography inside compact app panels.

## Commands

Use these from the repo root:

```bash
swift build
./script/test.sh
./script/build_and_run.sh
./script/build_and_run.sh --verify
```

For GUI changes, prefer `./script/build_and_run.sh --verify` before reporting done.

## Tests

- Add or update unit tests for non-trivial model, store, timing, receipt, or rule-matching logic.
- Run `./script/test.sh` before committing logic changes.
- This environment currently lacks `XCTest` / Swift `Testing`, so unit tests run through the `StillPointLogicTests` executable.
- If a UI-only change has no practical unit test, run `swift build` and `./script/build_and_run.sh --verify`.
- Record any skipped test and the reason in the final response or commit notes.

## Git

Commit and push frequently after coherent slices.

Use Conventional Commits:

- `feat: add deep work lock`
- `fix: prevent self-monitoring loop`
- `docs: capture product spec`
- `test: cover watch rule matching`
- `chore: wire run script`
- `refactor: split overlay presenter`

Before each commit:

```bash
git status --short
./script/test.sh
git add <files>
git commit -m "<type>: <summary>"
git push
```

If `./script/test.sh` is not meaningful yet, run `swift build` and explain why.

## Documentation

- Product decisions belong in `docs/product-spec.md`.
- Short positioning belongs in `docs/product-brief.md`.
- Stage goals and acceptance criteria belong in `GOAL.md`.
- Keep docs concise and update them when behavior changes.
