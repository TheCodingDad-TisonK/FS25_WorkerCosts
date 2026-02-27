-- =========================================================
-- FS25 Realistic Worker Costs Mod (version 1.0.0.8)
-- =========================================================
-- Hourly or per-hectare wages for workers
-- =========================================================
-- Author: TisonK
-- =========================================================
-- COPYRIGHT NOTICE:
-- All rights reserved. Unauthorized redistribution, copying,
-- or claiming this code as your own is strictly prohibited.
-- Original author: TisonK
-- =========================================================
local modDirectory = g_currentModDirectory
local modName = g_currentModName

-- Load all source files in correct order
source(modDirectory .. "src/settings/SettingsManager.lua")
source(modDirectory .. "src/settings/Settings.lua")
source(modDirectory .. "src/settings/WorkerSettingsGUI.lua") 
source(modDirectory .. "src/utils/UIHelper.lua")
source(modDirectory .. "src/settings/WorkerSettingsUI.lua")
source(modDirectory .. "src/WorkerSystem.lua")
source(modDirectory .. "src/WorkerManager.lua")

local wm

local function isEnabled()
    return wm ~= nil
end

local function loadedMission(mission, node)
    if not isEnabled() then
        return
    end
    
    if mission.cancelLoading then
        return
    end
    
    wm:onMissionLoaded()
end

local function load(mission)
    if wm == nil then
        print("Worker Costs Mod: Initializing...")
        wm = WorkerManager.new(mission, modDirectory, modName)
        getfenv(0)["g_WorkerManager"] = wm
        print("Worker Costs Mod: Initialized successfully")
    end
end

local function unload()
    if wm ~= nil then
        wm:delete()
        wm = nil
        getfenv(0)["g_WorkerManager"] = nil
    end
end

-- Hook into Mission lifecycle
Mission00.load = Utils.prependedFunction(Mission00.load, load)
Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadedMission)
FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

-- Update hook
FSBaseMission.update = Utils.appendedFunction(FSBaseMission.update, function(mission, dt)
    if wm then
        wm:update(dt)
    end
end)

-- Console command functions
function workerCosts()
    if g_WorkerManager and g_WorkerManager.WorkerSettingsGUI then
        return g_WorkerManager.WorkerSettingsGUI:consoleCommandHelp()
    else
        print("=== Worker Costs Mod Commands ===")
        print("Type these commands in console (~):")
        print("WorkerCostsShowSettings - Show current settings")
        print("WorkerCostsEnable/Disable - Enable/disable mod")
        print("WorkerCostsSetWageLevel 1|2|3 - Set wage level")
        print("WorkerCostsSetCostMode 1|2 - Set cost mode")
        print("WorkerCostsSetNotifications true|false - Toggle notifications")
        print("WorkerCostsTestPayment - Test wage payment")
        print("WorkerCostsResetSettings - Reset to defaults")
        print("==================================")
        return "Worker Costs Mod commands listed above"
    end
end

function workerCostsStatus()
    if g_WorkerManager and g_WorkerManager.settings then
        local settings = g_WorkerManager.settings
        local status = string.format(
            "=== Worker Costs Mod Status ===\n" ..
            "Enabled: %s\n" ..
            "Mode: %s\n" ..
            "Wage Level: %s\n" ..
            "Base Rate: $%d/h\n" ..
            "Notifications: %s\n" ..
            "================================",
            tostring(settings.enabled),
            settings:getCostModeName(),
            settings:getWageLevelName(),
            settings:getWageRate(),
            tostring(settings.showNotifications)
        )
        print(status)
        return status
    else
        print("Worker Costs Mod not initialized")
        return "Worker Costs Mod not initialized"
    end
end

-- Expose the two status/help functions as Lua globals so they can be called
-- from other mods or from the console directly.  All other commands are
-- registered exclusively via addConsoleCommand inside WorkerSettingsGUI.
getfenv(0)["workerCosts"] = workerCosts
getfenv(0)["workerCostsStatus"] = workerCostsStatus

print("========================================")
print("  Worker Costs Mod v1.0.0.8 LOADED      ")
print("  Type 'workerCosts' in console for help")
print("========================================")
