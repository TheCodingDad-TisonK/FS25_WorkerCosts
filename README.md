# Realistic Worker Costs

**Version:** 2.0.0
**Author:** TisonK
**Game:** Farming Simulator 25

---

## Overview

**Realistic Worker Costs** adds a comprehensive wage management system for AI workers in Farming Simulator 25. Workers now earn realistic wages based on their skill level, job type, and the difficulty setting you choose. Track detailed statistics, view real-time costs, and configure every aspect of worker payments.

---

## Features

- **Flexible Payment Models**
  - Hourly wages ($/hour)
  - Per-hectare wages ($/hectare)
  - Hybrid model (coming soon)

- **Skill-Based Wages**
  - Workers with higher skill levels earn more
  - Skill multiplier ranges from 0.8x to 1.4x base rate

- **Job-Type Modifiers**
  - Different jobs pay different rates
  - Harvesting and forestry pay more (1.2x)
  - Transport and fertilizing pay less (0.8-0.9x)

- **Configurable Presets**
  - **Casual**: Lower wages, gentle on farm economy ($15/hour)
  - **Realistic**: Balanced wages based on real farming costs ($25/hour)
  - **Hardcore**: High wages for maximum challenge ($40/hour)

- **Real-Time Tracking**
  - HUD overlay showing current worker costs
  - Detailed statistics dashboard
  - Payment history and analytics

- **Multiplayer Support**
  - Fully compatible with multiplayer games
  - Synchronized across all clients

---

## Installation

1. Download the latest release ZIP file
2. Extract to your FS25 mods folder:
   - **Windows**: `%USERPROFILE%\Documents\My Games\FarmingSimulator2025\mods`
   - **Mac/Linux**: `~/Documents/My Games/FarmingSimulator2025/mods`
3. Start Farming Simulator 25
4. Load a savegame or start a new game

---

## How to Use

### Accessing Settings

**IMPORTANT:** Worker Costs settings are accessed through the in-game menu, **NOT** via a hotkey.

1. **Load your game**
2. Press **ESC** to open the main menu
3. Select **Settings**
4. Scroll down to find the **"Worker Costs Settings"** section

The settings will be injected into the standard FS25 settings menu along with the game's built-in options.

### Available Settings

| Setting | Description | Options |
|---------|-------------|---------|
| **Enable Mod** | Turn the entire mod on/off | On/Off |
| **Wage Level** | Set base wage rate | Low, Medium, High, Custom |
| **Cost Mode** | Payment calculation method | Hourly, Per Hectare |
| **Payment Interval** | How often workers get paid | 1-60 minutes |
| **Show Cost Overlay** | Display HUD with current costs | On/Off |
| **Show Notifications** | Worker payment notifications | On/Off |

### Console Commands

Open the developer console (press `~` key) and type:

| Command | Description |
|---------|-------------|
| `wc` | Show all available commands |
| `wcShowSettings` | Display current settings |
| `wcShowStats` | Show detailed statistics |
| `wcShowWorkers` | List active workers and costs |
| `wcShowDashboard` | Open statistics dashboard |
| `wcHideDashboard` | Close statistics dashboard |
| `wcShowOverlay` | Enable HUD cost overlay |
| `wcHideOverlay` | Disable HUD cost overlay |
| `wcResetStats` | Reset all statistics |

---

## Payment Calculation

### Hourly Wage Formula

```
Final Wage = Base Rate × Hours Worked × Skill Multiplier × Job Type Multiplier
```

**Example:**
- Base Rate: $25/hour (Realistic preset)
- Hours Worked: 0.0833 hours (5 minutes)
- Skill Multiplier: 1.2 (expert worker)
- Job Type: Harvesting (1.2x multiplier)

```
Wage = $25 × 0.0833 × 1.2 × 1.2 = $3.00 per 5 minutes
```

### Per-Hectare Wage Formula

```
Final Wage = Base Rate × Hectares Worked × Skill Multiplier × Job Type Multiplier
```

**Example:**
- Base Rate: $75/hectare (Realistic preset)
- Hectares Worked: 2.5 hectares
- Skill Multiplier: 1.0 (intermediate worker)
- Job Type: Plowing (1.1x multiplier)

```
Wage = $75 × 2.5 × 1.0 × 1.1 = $206.25
```

---

## Job Type Multipliers

| Job Type | Multiplier | Rationale |
|----------|------------|-----------|
| Harvesting | 1.2x | Complex, high-value operation |
| Lumberjack/Forestry | 1.2x | Specialized, dangerous work |
| Plowing | 1.1x | Heavy equipment, requires skill |
| Seeding/Sowing | 1.0x | Standard field work |
| Cultivating | 1.0x | Standard field work |
| Baling/Wrapping | 1.0x | Standard field work |
| Cotton/Grass | 1.0x | Standard field work |
| Fertilizing | 0.9x | Simpler operation |
| Spraying | 0.9x | Simpler operation |
| Transport | 0.8x | Least complex work |

---

## Presets

### Casual ($15/hour or $45/hectare)
- Lower wages for relaxed gameplay
- Payment every 10 minutes
- Skill multipliers disabled
- Good for: New players, casual farming

### Realistic ($25/hour or $75/hectare)
- Balanced wages based on real farming costs
- Payment every 5 minutes
- Skill multipliers enabled
- Good for: Most players, balanced challenge

### Hardcore ($40/hour or $120/hectare)
- High wages for maximum challenge
- Payment every 2 minutes
- Skill multipliers enabled
- Good for: Experienced players, economic challenge

---

## Troubleshooting

### Settings Don't Appear in Menu

1. Make sure the mod is installed correctly in the mods folder
2. Check the game log for errors: `%USERPROFILE%\Documents\My Games\FarmingSimulator2025\log.txt`
3. Look for lines starting with `[WorkerCosts]`
4. If you see errors about missing files, reinstall the mod

### Workers Not Being Charged

1. Open console (`~` key) and type `wcShowWorkers`
2. Verify workers are detected
3. Check if mod is enabled: type `wcShowSettings`
4. Make sure you have AI workers actually working (not just hired and idle)

### Costs Seem Wrong

1. Check your wage level: type `wcShowSettings`
2. Remember that skill multipliers affect wages (0.8x to 1.4x)
3. Job type multipliers also apply (0.8x to 1.2x)
4. If using per-hectare mode, costs depend on area worked, not time

---

## FAQ

**Q: How do I open the settings?**
A: Press ESC → Settings → Scroll down to "Worker Costs Settings"

**Q: Is there a hotkey to open settings?**
A: No, there is no hotkey. Use the in-game Settings menu.

**Q: Can I disable the mod temporarily?**
A: Yes, open Settings and toggle "Enable Mod" to Off.

**Q: Does this work in multiplayer?**
A: Yes, fully compatible. All players see synchronized data.

**Q: Do workers from other mods work with this?**
A: Yes, as long as they use the standard FS25 AI worker system.

**Q: Can I change settings mid-game?**
A: Yes, all settings can be changed at any time.

**Q: Why are my costs higher than expected?**
A: Check skill multipliers and job type multipliers. A skilled harvester might earn 1.2 (skill) × 1.2 (job type) = 1.44x the base rate.

---

## Support

- **Report Issues:** [GitHub Issues](https://github.com/yourusername/FS25_WorkerCosts/issues)
- **Game Log Location:** `%USERPROFILE%\Documents\My Games\FarmingSimulator2025\log.txt`
- **Mod Version:** Check console output when game loads

---

## Credits

**Author:** TisonK
**Version:** 2.0.0
**Last Updated:** February 16, 2026

---

## License

All rights reserved. Unauthorized redistribution, copying, or claiming this code as your own is strictly prohibited.

**Original author:** TisonK
