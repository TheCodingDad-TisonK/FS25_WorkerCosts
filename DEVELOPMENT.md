# DEVELOPMENT.md
## FS25_WorkerCosts — Build Tracker & Session Log

> **Purpose:** This file is the single source of truth for what has been built, what hasn't, and where the next session should begin. Every AI (Claude, GPT, Gemini, or any other) working on this project MUST read this file first, update it when done, and leave it better than they found it.

---

## How to Use This File (Read Before Touching Anything)

### For AI Agents Starting a Session

1. **Read this entire file first.** Do not skip to the TODO list.
2. **Find the last completed session** in the Session Log (bottom of file). That tells you exactly where to start.
3. **Find the first unchecked item** in the TODO list. That is your starting point.
4. **Follow the collaboration model** in `CLAUDE.md` — planning dialog with Samantha before writing code, review dialog after.
5. **When you finish a work block**, scroll to the Session Log section and add an entry. Be specific. Future AIs depend on your notes.
6. **Check off TODO items** as you complete them. Use `[x]` for done, `[~]` for partial/in-progress, `[ ]` for not started.
7. **Never mark something `[x]` unless it is tested and working.** `[~]` means started but not complete.

### Status Key

| Symbol | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[~]` | In progress / partial |
| `[x]` | Complete and tested |
| `[!]` | Blocked — see notes |
| `[s]` | Skipped — see notes (usually optional or deferred) |

---

## Current State (v1.0.0.8)

The mod is functional and published. Core systems are complete and working:

- Worker detection via game's AI worker system ✓
- Real-time wage accumulation (dt-based, not game time) ✓
- Hourly and per-hectare cost modes ✓
- Three wage tiers (Low/Medium/High) with skill multipliers ✓
- Custom rate override ✓
- Game's built-in worker cost hook disabled (prevents double-charging) ✓
- In-game Settings menu injection ✓
- Console commands ✓
- Save/load via sidecar XML ✓
- Multiplayer support ✓
- 10-language localization ✓

---

## Master TODO List

Work through these **in order**. Do not skip ahead unless dependencies allow.

---

### PHASE 1 — Core MVP
*(All complete as of v1.0.0.8)*

- [x] Worker detection (AI worker tracking)
- [x] Real-time payment accumulation
- [x] Hourly cost mode
- [x] Per-hectare cost mode
- [x] Wage tiers: Low / Medium / High
- [x] Skill multiplier (80%–120%)
- [x] Disable game's built-in worker costs
- [x] In-game settings menu injection
- [x] Console commands
- [x] Save/load settings
- [x] Payment notifications
- [x] Debug mode + log prefix

---

### PHASE 2 — Polish & QA

- [ ] Verify per-hectare tracking works across all implement types
  - Known issue: some implements don't report area worked — falls back to hourly silently
  - Should notify player when falling back
- [ ] Verify modded AI workers are detected (third-party worker mods)
- [ ] Test multiplayer: host vs client payment deduction behavior
- [ ] Confirm settings persist correctly across save/load cycles
- [ ] Stress test: many workers active simultaneously

---

### PHASE 3 — Planned Features

- [ ] Configurable payment interval (currently hardcoded at 5 real minutes)
- [ ] Per-job-type wage rates (e.g., harvesting costs more than seeding)
- [ ] Worker performance bonuses / penalties
- [ ] Statistics screen: total wages paid, workers hired, hours worked
- [ ] Wage history log (last N payments)

---

### PHASE 4 — Optional / Future

- [s] Integration with FS25_IncomeMod (deduct from income tracking)
- [s] Integration with FS25_TaxMod (workers as deductible expense)
- [ ] UI: dedicated Workers tab in settings instead of injecting into general settings

---

## Known Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| Per-hectare tracking incomplete for some implements | Medium | Falls back to hourly silently — no user feedback |
| Some third-party AI worker mods not detected | Low | Depends on whether they use standard helper API |
| Payment interval not configurable | Low | Planned for Phase 3 |

---

## Architecture Snapshot

```
src/
├── main.lua                     Entry point, hooks, console commands
├── WorkerManager.lua            Central coordinator (g_WorkerManager)
├── WorkerSystem.lua             Worker tracking + payment engine
├── settings/
│   ├── Settings.lua             Settings values + accessors
│   ├── SettingsManager.lua      XML load/save
│   ├── WorkerSettingsGUI.lua    Console command handlers
│   └── WorkerSettingsUI.lua     In-game settings menu injection
└── utils/
    └── UIHelper.lua             Shared UI utilities
```

Load order in `main.lua`:
1. SettingsManager → Settings → WorkerSettingsGUI → UIHelper → WorkerSettingsUI → WorkerSystem → WorkerManager

---

## Session Log

---

### Session — 2026-02-10 (approx) | v1.0.0.7
**What was done:**
- Fixed worker detection reliability
- Improved worker tracking accuracy
- Better error handling throughout

---

### Session — 2026-02-27 | v1.0.0.8
**What was done:**
- Fixed double-charging: game's built-in `addMoneyForHelper` hook now zeroed out by mod (`installGameHook`)
- Fixed wage calculation: replaced `dayTime`-based timing with real-time `dt` accumulation — was overcharging ~20×
- Added CLAUDE.md and DEVELOPMENT.md tailored to this project

**What's next:**
- Phase 2 QA: per-hectare fallback notification, multiplayer testing
