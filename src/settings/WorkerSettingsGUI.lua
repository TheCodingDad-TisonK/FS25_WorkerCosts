-- =========================================================
-- FS25 Worker Costs Mod (version 1.0.0.9)
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
---@class WorkerSettingsGUI

WorkerSettingsGUI = {}
local WorkerSettingsGUI_mt = Class(WorkerSettingsGUI)

function WorkerSettingsGUI.new()
    local self = setmetatable({}, WorkerSettingsGUI_mt)
    return self
end

function WorkerSettingsGUI:registerConsoleCommands()
    addConsoleCommand("WorkerCostsSetWageLevel", "Set wage level (1=Low, 2=Medium, 3=High)", "consoleCommandSetWageLevel", self)
    
    addConsoleCommand("WorkerCostsEnable", "Enable Worker Costs Mod", "consoleCommandWorkerCostsEnable", self)
    addConsoleCommand("WorkerCostsDisable", "Disable Worker Costs Mod", "consoleCommandWorkerCostsDisable", self)
    addConsoleCommand("WorkerCostsSetCostMode", "Set cost mode (1=Hourly, 2=Per Hectare)", "consoleCommandSetCostMode", self)
    addConsoleCommand("WorkerCostsSetNotifications", "Enable/disable notifications (true/false)", "consoleCommandSetNotifications", self)
    addConsoleCommand("WorkerCostsSetCustomRate", "Set custom wage rate (0 = use wage level)", "consoleCommandSetCustomRate", self)
    addConsoleCommand("WorkerCostsTestPayment", "Test wage payment system", "consoleCommandTestPayment", self)
    
    addConsoleCommand("WorkerCostsShowSettings", "Show current settings", "consoleCommandShowSettings", self)
    
    addConsoleCommand("WorkerCostsResetSettings", "Reset all settings to defaults", "consoleCommandResetSettings", self)
    
    addConsoleCommand("workerCosts", "Show all worker costs commands", "consoleCommandHelp", self)
    addConsoleCommand("workerCostsStatus", "Show current mod status", "consoleCommandShowSettings", self)

    Logging.info("Worker Costs Mod console commands registered")
end

function WorkerSettingsGUI:consoleCommandHelp()
    print("=== Worker Costs Mod Console Commands ===")
    print("workerCosts - Show this help")
    print("WorkerCostsEnable/Disable - Toggle mod")
    print("WorkerCostsSetWageLevel 1|2|3 - Set wage level")
    print("WorkerCostsSetCostMode 1|2 - Set payment mode")
    print("WorkerCostsSetNotifications true|false - Toggle notifications")
    print("WorkerCostsSetCustomRate <rate> - Set custom rate (0 for default)")
    print("WorkerCostsTestPayment - Test payment system")
    print("WorkerCostsShowSettings - Show current settings")
    print("WorkerCostsResetSettings - Reset to defaults")
    print("===========================================")
    return "Type 'workerCosts' for more info"
end

function WorkerSettingsGUI:consoleCommandSetWageLevel(wageLevel)
    local level = tonumber(wageLevel)
    if not level or level < 1 or level > 3 then
        Logging.warning("Invalid wage level. Use 1 (Low), 2 (Medium), or 3 (High)")
        return "Invalid wage level"
    end
    
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings:setWageLevel(level)
        g_WorkerManager.settings:save()
        return string.format("Wage level set to: %s ($%d/h)", 
            g_WorkerManager.settings:getWageLevelName(),
            g_WorkerManager.settings:getWageRate())
    end
    
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandWorkerCostsEnable()
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings.enabled = true
        g_WorkerManager.settings:save()
        
        if g_WorkerManager.workerSystem then
            g_WorkerManager.workerSystem:initialize()
        end
        
        return "Worker Costs Mod enabled"
    end
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandWorkerCostsDisable()
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings.enabled = false
        g_WorkerManager.settings:save()
        return "Worker Costs Mod disabled"
    end
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandSetCostMode(mode)
    local costMode = tonumber(mode)
    if not costMode or (costMode ~= 1 and costMode ~= 2) then
        return "Invalid cost mode. Use 1 (Hourly) or 2 (Per Hectare)"
    end
    
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings:setCostMode(costMode)
        g_WorkerManager.settings:save()
        return string.format("Cost mode set to: %s", g_WorkerManager.settings:getCostModeName())
    end
    
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandSetNotifications(enabled)
    if enabled == nil then
        return "Usage: WorkerCostsSetNotifications true|false"
    end
    
    local enable = enabled:lower()
    if enable ~= "true" and enable ~= "false" then
        return "Invalid value. Use 'true' or 'false'"
    end
    
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings.showNotifications = (enable == "true")
        g_WorkerManager.settings:save()
        return string.format("Notifications %s", g_WorkerManager.settings.showNotifications and "enabled" or "disabled")
    end
    
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandSetCustomRate(rate)
    local customRate = tonumber(rate)
    if not customRate or customRate < 0 then
        return "Invalid rate. Use a positive number or 0 to use wage level setting"
    end
    
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings.customRate = customRate
        g_WorkerManager.settings:save()
        if customRate > 0 then
            return string.format("Custom rate set to: $%d/h", customRate)
        else
            return "Custom rate disabled, using wage level setting"
        end
    end
    
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandTestPayment()
    if g_WorkerManager and g_WorkerManager.settings then
        if g_WorkerManager.workerSystem then
            local success = g_WorkerManager.workerSystem:testPayment()
            if success then
                return "Test payment executed (-$100)"
            else
                return "Test payment failed"
            end
        end
    end
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandShowSettings()
    if g_WorkerManager and g_WorkerManager.settings then
        local settings = g_WorkerManager.settings
        local info = string.format(
            "=== Worker Costs Mod Settings ===\n" ..
            "Enabled: %s\n" ..
            "Debug Mode: %s\n" ..
            "Cost Mode: %s\n" ..
            "Wage Level: %s\n" ..
            "Wage Rate: $%d/h\n" ..
            "Notifications: %s\n" ..
            "Custom Rate: $%d/h\n" ..
            "================================",
            tostring(settings.enabled),
            tostring(settings.debugMode),
            settings:getCostModeName(),
            settings:getWageLevelName(),
            settings:getWageRate(),
            tostring(settings.showNotifications),
            settings.customRate
        )
        print(info)
        return info
    end
    
    return "Error: Worker Costs Mod not initialized"
end

function WorkerSettingsGUI:consoleCommandResetSettings()
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings:resetToDefaults()

        -- Refresh UI widgets to reflect restored defaults
        if g_WorkerManager.WorkerSettingsUI then
            g_WorkerManager.WorkerSettingsUI:refreshUI()
        end

        return "Worker Costs Mod settings reset to defaults"
    end

    return "Error: Worker Costs Mod not initialized"
end