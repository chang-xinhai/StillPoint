# StillPoint

Protect the pause before the feed.

StillPoint is a macOS-first attention interruption prototype for detecting
unconscious app use and creating a deliberate pause before the user falls into
doomscrolling.

## Prototype Direction

- Start on macOS for fast, real-device validation.
- Watch selected foreground apps and browser contexts.
- Trigger a full-screen pause after sustained unintentional use.
- Ask the user to state intent before continuing.
- Record sessions locally as an attention receipt.
- Keep Android as the next migration target.

## Today

The exam demo should prove the core loop:

1. Configure distracting apps or sites.
2. Open a watched app.
3. Stay there long enough to trigger StillPoint.
4. See a full-screen intervention.
5. Choose to continue, leave, or mark the session as intentional.
6. Review the attention receipt.

## Run

```bash
./script/build_and_run.sh
```

For a launch check:

```bash
./script/build_and_run.sh --verify
```

## Demo Script

1. Open StillPoint with Demo Mode enabled.
2. Click `Simulate drift`.
3. Show the full-screen StillPoint intervention.
4. Choose `Looking something up` to grant a bounded pass.
5. Run the simulation again and choose `I drifted`.
6. Open `Daily Receipt` to show the daily summary.
7. Start `Deep Work Lock` to show the stricter coding-session guard.
