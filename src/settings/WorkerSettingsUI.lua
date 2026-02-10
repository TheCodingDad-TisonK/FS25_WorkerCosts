-- =========================================================
-- FS25 Worker Costs Mod (version 1.0.0.5)
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
---@class WorkerSettingsUI
WorkerSettingsUI = {}
local WorkerSettingsUI_mt = Class(WorkerSettingsUI)

function WorkerSettingsUI.new(settings)
    local self = setmetatable({}, WorkerSettingsUI_mt)
    self.settings = settings
    self.injected = false
    return self
end

function WorkerSettingsUI:inject()
    if self.injected then 
        return 
    end
    
    local page = g_gui.screenControllers[InGameMenu].pageSettings
    if not page then
        Logging.error("wc: Settings page not found - cannot inject settings!")
        return 
    end
    
    local layout = page.generalSettingsLayout
    if not layout then
        Logging.error("wc: Settings layout not found!")
        return 
    end
    
    local section = UIHelper.createSection(layout, "wc_section")
    if not section then
        Logging.error("wc: Failed to create settings section!")
        return
    end
    
    local enabledOpt = UIHelper.createBinaryOption(
        layout,
        "wc_enabled",
        "wc_enabled",
        self.settings.enabled,
        function(val)
            self.settings.enabled = val
            self.settings:save()
            print("Worker Costs Mod: " .. (val and "Enabled" or "Disabled"))
        end
    )
    
    local debugOpt = UIHelper.createBinaryOption(
        layout,
        "wc_debug",
        "wc_debug",
        self.settings.debugMode,
        function(val)
            self.settings.debugMode = val
            self.settings:save()
            print("Worker Costs Mod: Debug mode " .. (val and "enabled" or "disabled"))
            if self.debugOption and self.debugOption.setState then
                self.debugOption:setState(val and 2 or 1)
            end
        end
    )
    
    local costModeOptions = {
        getTextSafe("wc_costmode_1"),
        getTextSafe("wc_costmode_2")
    }
    
    local costModeOpt = UIHelper.createMultiOption(
        layout,
        "wc_costmode",
        "wc_costmode",
        costModeOptions,
        self.settings.costMode,
        function(val)
            self.settings.costMode = val
            self.settings:save()
            local modeName = val == 1 and "Hourly" or "Per Hectare"
            print("Worker Costs Mod: Cost mode set to " .. modeName)
        end
    )
    
    local wageOptions = {
        getTextSafe("wc_diff_1"),
        getTextSafe("wc_diff_2"),
        getTextSafe("wc_diff_3")
    }
    
    local wageOpt = UIHelper.createMultiOption(
        layout,
        "wc_wage",
        "wc_difficulty",
        wageOptions,
        self.settings.wageLevel,
        function(val)
            self.settings.wageLevel = val
            self.settings:save()
            print("Worker Costs Mod: Wage level set to " .. self.settings:getWageLevelName())
        end
    )
    
    local notificationsOpt = UIHelper.createBinaryOption(
        layout,
        "wc_notifications",
        "wc_notifications",
        self.settings.showNotifications,
        function(val)
            self.settings.showNotifications = val
            self.settings:save()
            print("Worker Costs Mod: Notifications " .. (val and "enabled" or "disabled"))
            if self.notificationsOption and self.notificationsOption.setState then
                self.notificationsOption:setState(val and 2 or 1)
            end
        end
    )
    
    self.enabledOption = enabledOpt
    self.debugOption = debugOpt
    self.costModeOption = costModeOpt
    self.wageLevelOption = wageOpt
    self.notificationsOption = notificationsOpt
    
    self.injected = true
    layout:invalidateLayout()
    
    print("Worker Costs Mod: Settings UI injected successfully")
end


function getTextSafe(key)
    local text = g_i18n:getText(key)
    if text == nil or text == "" then
        return key
    end
    return text
end

function WorkerSettingsUI:refreshUI()
    if not self.injected then
        return
    end
    
    if self.enabledOption and self.enabledOption.setIsChecked then
        self.enabledOption:setIsChecked(self.settings.enabled)
    elseif self.enabledOption and self.enabledOption.setState then
        self.enabledOption:setState(self.settings.enabled and 2 or 1)
    end
    
    if self.debugOption and self.debugOption.setIsChecked then
        self.debugOption:setIsChecked(self.settings.debugMode)
    elseif self.debugOption and self.debugOption.setState then
        self.debugOption:setState(self.settings.debugMode and 2 or 1)
    end
    
    if self.costModeOption and self.costModeOption.setState then
        self.costModeOption:setState(self.settings.costMode)
    end
    
    if self.wageLevelOption and self.wageLevelOption.setState then
        self.wageLevelOption:setState(self.settings.wageLevel)
    end
    
    if self.notificationsOption and self.notificationsOption.setIsChecked then
        self.notificationsOption:setIsChecked(self.settings.showNotifications)
    elseif self.notificationsOption and self.notificationsOption.setState then
        self.notificationsOption:setState(self.settings.showNotifications and 2 or 1)
    end
    
    print("Worker Costs Mod: UI refreshed")
end

function WorkerSettingsUI:ensureResetButton(settingsFrame)
    if not settingsFrame or not settingsFrame.menuButtonInfo then
        print("wc: ensureResetButton - settingsFrame invalid")
        return
    end
    
    if not self._resetButton then
        self._resetButton = {
            inputAction = InputAction.MENU_EXTRA_1,
            text = g_i18n:getText("wc_reset") or "Reset Settings",
            callback = function()
                print("wc: Reset button clicked!")
                if g_WorkerManager and g_WorkerManager.settings then
                    g_WorkerManager.settings:resetToDefaults()
                    if g_WorkerManager.WorkerSettingsUI then
                        g_WorkerManager.WorkerSettingsUI:refreshUI()
                    end
                end
            end,
            showWhenPaused = true
        }
    end
    
    for _, btn in ipairs(settingsFrame.menuButtonInfo) do
        if btn == self._resetButton then
            print("wc: Reset button already in menuButtonInfo")
            return
        end
    end
    
    table.insert(settingsFrame.menuButtonInfo, self._resetButton)
    settingsFrame:setMenuButtonInfoDirty()
    print("wc: Reset button added to footer! (X key)")
end