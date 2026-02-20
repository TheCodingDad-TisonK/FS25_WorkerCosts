<<<<<<< development
# FS25 Realistic Worker Costs Mod

![Downloads](https://img.shields.io/github/downloads/TheCodingDad-TisonK/FS25_WorkerCosts/total?style=for-the-badge)
![Release](https://img.shields.io/github/v/release/TheCodingDad-TisonK/FS25_WorkerCosts?style=for-the-badge)
![License](https://img.shields.io/badge/license-All%20Rights%20Reserved-red?style=for-the-badge)
=======
# Realistic Worker Costs
![Downloads](https://img.shields.io/github/downloads/TheCodingDad-TisonK/FS25_WorkerCosts/total?style=for-the-badge)
![Release](https://img.shields.io/github/v/release/TheCodingDad-TisonK/FS25_WorkerCosts?style=for-the-badge)
![License](https://img.shields.io/badge/license-All%20Rights%20Reserved-red?style=for-the-badge)

---
>>>>>>> main

## Overview
Adds realistic hourly or per-hectare wage costs for hired workers in Farming Simulator 25. This mod introduces ongoing expenses for using workers, making farm management more challenging and strategic.

## Features
- **Configurable Wage System**: Choose between hourly or per-hectare payment modes
- **Three Wage Levels**: Low ($15/h), Medium ($25/h), High ($40/h) base rates
- **Skill-Based Pricing**: Workers with higher skills earn higher wages (80%-120% multiplier)
- **In-Game Settings**: Full integration with game settings menu
- **Console Commands**: Control all settings via in-game console
- **Multiplayer Support**: Works in multiplayer games
- **Multi-Language**: Supports 10 languages
- **Save Game Compatible**: Settings save with your game
- **Real Worker Tracking**: Automatically detects and charges for active AI workers
- **Periodic Payments**: Workers are paid every 5 in-game minutes

## Installation

### Directory Structure
The mod should be structured as follows:
```
FS25_WorkerCostsMod/
├── modDesc.xml
├── icon.dds
└── src/
    ├── main.lua
    ├── WorkerSystem.lua
    ├── WorkerManager.lua
    ├── settings/
    │   ├── Settings.lua
    │   ├── SettingsManager.lua
    │   ├── WorkerSettingsGUI.lua
    │   └── WorkerSettingsUI.lua
    └── utils/
        └── UIHelper.lua
```

### Installation Steps
1. Download the mod archive
2. Extract to your Farming Simulator 25 mods folder:
   - Windows: `Documents/My Games/FarmingSimulator2025/mods/`
   - Steam: Check game properties for exact path
3. Enable the mod in the mod menu when starting a game

## Configuration

### Access Settings
1. **In-Game Menu**: Pause → Settings → Worker Costs Mod section
2. **Console Commands**: Type `workerCosts` for help

### Main Settings
- **Enable/Disable**: Toggle the mod on/off
- **Cost Mode**: Hourly ($/h) or Per Hectare ($/ha)
- **Wage Level**: Low, Medium, or High base rates
- **Custom Rate**: Set your own wage rate (0 = use Wage Level)
- **Notifications**: Toggle payment notifications
- **Debug Mode**: Extra logging for troubleshooting

## Console Commands

Type these in the console (`~` key):

| Command | Description |
|---------|-------------|
| `workerCosts` | Show all available commands |
| `workerCostsStatus` | Show current mod status |
| `workerCostsEnable` | Enable the mod |
| `workerCostsDisable` | Disable the mod |
| `WorkerCostsSetWageLevel 1\|2\|3` | Set wage level (1=Low, 2=Medium, 3=High) |
| `WorkerCostsSetCostMode 1\|2` | Set cost mode (1=Hourly, 2=Per Hectare) |
| `WorkerCostsSetNotifications true\|false` | Toggle notifications |
| `WorkerCostsSetCustomRate <amount>` | Set custom wage rate |
| `WorkerCostsTestPayment` | Test wage payment system |
| `WorkerCostsShowSettings` | Show current settings |
| `WorkerCostsResetSettings` | Reset to defaults |

## How It Works

### Worker Detection
- The mod automatically detects all active AI workers in your game
- Workers are tracked from the moment they start working
- Each worker's time and work is tracked independently

### Payment System
- Workers are paid every 5 in-game minutes
- Payments are based on actual work performed since last payment
- In Hourly mode: Calculated based on in-game time worked
- In Per Hectare mode: Calculated based on area worked (when available)

### Wage Calculation Examples

#### Hourly Mode
- Low wage level: $15/h × skill multiplier
- Medium wage level: $25/h × skill multiplier  
- High wage level: $40/h × skill multiplier
- Example: Medium wage worker with 100% skill = $30/hour (25 × 1.2)

#### Per Hectare Mode
- Uses same rates but calculates based on hectares worked
- Example: Medium wage = $25 per hectare worked
- Multiplied by skill level (80%-120%)

#### Skill Multipliers
- 0% skill: 80% of base rate (0.8x)
- 50% skill: 100% of base rate (1.0x)
- 100% skill: 120% of base rate (1.2x)

## Compatibility
- **Game Version**: Farming Simulator 25
- **Multiplayer**: Fully supported
- **Other Mods**: Should be compatible with most mods
- **Save Games**: Can be added/removed from existing saves

## Troubleshooting

### Mod not showing in settings
1. Ensure it's enabled in the mod menu
2. Check that all files are in the correct directories
3. Look for errors in the log file

### No wage charges
1. Verify mod is enabled (`workerCostsStatus` command)
2. Ensure AI workers are actually active
3. Enable debug mode to see detailed logging
4. Check that you have enough money (negative balance stops charges)

### Settings not saving
1. Check file permissions in save game folder
2. Ensure the mod has write access
3. Try manually deleting the mod's XML file in the savegame folder

### Workers not being detected
1. Enable debug mode in settings
2. Check console for "[Worker Costs]" messages
3. Ensure workers are hired through the game's AI system
4. Try the `workerCostsTest` command to verify the payment system works

### Log File Location
- Windows: `Documents/My Games/FarmingSimulator2025/log.txt`
- Look for lines starting with "[Worker Costs]"

## Debug Mode

Enable debug mode for detailed logging:
1. In-game settings: Enable "DEBUG Mode"
2. Console command: Enable mod, then check logs
3. All worker tracking and payment operations will be logged

## Version History
- **v1.0.0.7** (2026-02-10): Fixed worker detection, improved tracking, better error handling
- **v1.0.0.5** (2025-01-20): Bug fixes and stability improvements
- **v1.0.0.0** (2024-01-15): Initial release

## Known Issues
- Per-hectare tracking may not work for all vehicle/implement combinations
- Some modded AI workers might not be detected
- Payment intervals are fixed at 5 in-game minutes

## Planned Features
- Configurable payment intervals
- Per-job type wage rates
- Worker performance bonuses/penalties
- Detailed statistics and reports

## Credits
- **Author**: TisonK
- **Testing**: Community contributors
- **Special Thanks**: FS25 modding community

## Support
For bugs or suggestions:
- GitHub Issues: https://github.com/TheCodingDad-TisonK/FS25_WorkerCosts/issues
- Report on mod hosting sites
- Contact the author

## License
All rights reserved. Do not redistribute or claim as your own work.

---

**Note**: This mod modifies game economy. Use at your own discretion.
