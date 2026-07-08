# StillPoint

Protect the pause before the feed.

StillPoint is a macOS-first menu bar attention interruption prototype for detecting
unconscious app use and creating a deliberate pause before the user falls into
doomscrolling.

## Prototype Direction

- Start on macOS for fast, real-device validation.
- Live primarily in the menu bar, not as a full-time dashboard.
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

StillPoint launches as a menu bar agent with no Dock icon and a glass Control
Center window for demos. Close the window anytime; the menu bar agent keeps
watching. Use the menu bar item to start Deep Work Lock, trigger the demo, or
reopen Control Center.

For a launch check:

```bash
./script/build_and_run.sh --verify
```

## Demo Script

1. Open StillPoint with Demo Mode enabled.
2. Show the glass Control Center with the live frontmost app.
3. Click `Simulate drift`.
4. Show the full-screen StillPoint intervention.
5. Choose `Looking something up` to grant a bounded pass.
6. Run the simulation again and choose `I drifted`.
7. Open `Daily Receipt`.
8. Close the window and show StillPoint still running in the menu bar.
9. Start `Work Lock` from the menu bar panel.
