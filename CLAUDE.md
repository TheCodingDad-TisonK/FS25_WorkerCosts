# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

```bash
bash build.sh --deploy
```

This zips the mod and copies it to `C:\Users\tison\Documents\My Games\FarmingSimulator2025\mods`. After deploying, check `log.txt` in that directory for errors tagged with `[Worker Costs]` or `Worker Costs Mod:`.

There is no test runner. Testing is done in-game. Use the in-game console (`~`) with `workerCosts` for help and `workerCostsStatus` for current state.

## Architecture

The mod is a single Lua entrypoint (`src/main.lua`) that `source()`s all other files in load order, then hooks into the FS25 mission lifecycle via `Utils.prependedFunction` / `Utils.appendedFunction`.

**Core object graph** (created in `main.lua` → `WorkerManager.new()`):

```
WorkerManager          — top-level coordinator; owns all subsystems
  SettingsManager      — XML persistence (saves to savegame directory)
  Settings             — in-memory settings model; wraps SettingsManager
  WorkerSystem         — wage accumulation, payment timer, addMoney hook
  WorkerSettingsUI     — injects rows into the vanilla Settings screen
  WorkerSettingsGUI    — registers console commands (~)
```

**GUI layer** (client-only, loaded after map via `WCModGui:onMapLoaded()`):

```
WCModGui               — registers the icon tab in InGameMenu
  WCMenuPage           — the tab page (entry point from pause menu)
  WCGui                — inner TabbedMenu controller
    WCDashboardFrame   — Dashboard tab
    WCWageSettingsFrame — Wage Settings tab
```

XML layouts live in `xml/gui/`. Custom GUI profiles are loaded from `xml/gui/guiProfiles.xml`.

**Key design decisions:**

- The game's built-in `MoneyType.WORKER_WAGES` deductions are suppressed by patching `mission.addMoney` in `WorkerSystem:installGameHook()`. The `_isProcessingPayment` flag lets the mod's own charges pass through.
- All timing uses real-time `dt` (milliseconds), not `environment.dayTime`, to avoid ~20x overcharge at high game speeds.
- Wages are accumulated per-vehicle ID every frame and settled every 5 real minutes (`paymentInterval = 300000`).
- Workers dismissed mid-interval are paid out at the next settlement tick using `workerNames` / `workerHours` / `workerHectares` tables keyed by `tostring(vehicle)`.
- Settings persist per-savegame as `<savegameDirectory>/FS25_WorkerCostsMod.xml`.
- The global `g_WorkerManager` exposes the manager to other mods and console commands.

## Console Commands (in-game `~`)

| Command | Effect |
|---|---|
| `workerCosts` | Show all available commands |
| `workerCostsStatus` | Print current settings |
| `WorkerCostsShowSettings` | Detailed settings dump |
| `WorkerCostsEnable` / `WorkerCostsDisable` | Toggle mod |
| `WorkerCostsSetWageLevel 1\|2\|3` | Low/Medium/High |
| `WorkerCostsSetCostMode 1\|2` | Hourly / Per Hectare |
| `WorkerCostsSetNotifications true\|false` | Toggle HUD popups |
| `WorkerCostsTestPayment` | Deduct $100 test charge |
| `WorkerCostsResetSettings` | Reset to defaults |
| `wcReloadGui` | Reload GUI without restarting |

## Settings

| Field | Default | Notes |
|---|---|---|
| `enabled` | `true` | Master on/off switch |
| `costMode` | `1` (Hourly) | `1` = $/h, `2` = $/ha |
| `wageLevel` | `2` (Medium) | `1`=\$15/h, `2`=\$25/h, `3`=\$40/h |
| `customRate` | `0` | Overrides wageLevel when > 0 |
| `showNotifications` | `true` | HUD payment popups |
| `debugMode` | `false` | Enables `[Worker Costs]` log lines |
