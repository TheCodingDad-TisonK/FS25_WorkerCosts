# FS25 Realistic Worker Costs Mod

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

## Installation
1. Download the mod archive
2. Extract to your Farming Simulator 25 mods folder:
   - Windows: `Documents/My Games/FarmingSimulator2025/mods/`
   - Steam: Check game properties for exact path
3. Enable the mod in the mod menu when starting a game

## Configuration
Access settings through:
1. **In-Game Menu**: Pause → Settings → Worker Costs Mod section
2. **Console Commands**: Type `workerCosts` for help

### Main Settings:
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
| `WorkerCostsEnable/Disable` | Toggle the mod |
| `WorkerCostsSetWageLevel 1\|2\|3` | Set wage level (1=Low, 2=Medium, 3=High) |
| `WorkerCostsSetCostMode 1\|2` | Set cost mode (1=Hourly, 2=Per Hectare) |
| `WorkerCostsSetNotifications true\|false` | Toggle notifications |
| `WorkerCostsSetCustomRate <amount>` | Set custom wage rate |
| `WorkerCostsTestPayment` | Test wage payment system |
| `WorkerCostsShowSettings` | Show current settings |
| `WorkerCostsResetSettings` | Reset to defaults |

## Wage Calculation Examples

### Hourly Mode:
- Low wage level: $15/h × skill multiplier
- Medium wage level: $25/h × skill multiplier  
- High wage level: $40/h × skill multiplier
- Example: Medium wage worker with 100% skill = $25/hour

### Per Hectare Mode:
- Uses same rates but calculates based on hectares worked
- Example: Medium wage = $25 per hectare worked

### Skill Multipliers:
- 0% skill: 80% of base rate
- 50% skill: 100% of base rate
- 100% skill: 120% of base rate

## Compatibility
- **Game Version**: Farming Simulator 25
- **Multiplayer**: Fully supported
- **Other Mods**: Should be compatible with most mods
- **Save Games**: Can be added/removed from existing saves

## Troubleshooting
1. **Mod not showing in settings**: Ensure it's enabled in mod menu
2. **No wage charges**: Check mod is enabled and workers are active
3. **Settings not saving**: Check file permissions in save game folder

## Version History
- **v1.0.0.0** (2024-01-15): Initial release

## Credits
- **Author**: TisonK

## Support
For bugs or suggestions, please report on mod hosting sites or contact the author.

## License
All rights reserved. Do not redistribute or claim as your own work.