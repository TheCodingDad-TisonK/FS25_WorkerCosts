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
---@class WorkerManager
WorkerManager = {}
local WorkerManager_mt = Class(WorkerManager)

function WorkerManager.new(mission, modDirectory, modName)
    local self = setmetatable({}, WorkerManager_mt)
    
    self.mission = mission
    self.modDirectory = modDirectory
    self.modName = modName
    
    self.settingsManager = SettingsManager.new()
    self.settings = Settings.new(self.settingsManager)
    
    self.workerSystem = WorkerSystem.new(self.settings)
    
    if mission:getIsClient() and g_gui then
        self.WorkerSettingsUI = WorkerSettingsUI.new(self.settings)
        
        InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
            self.WorkerSettingsUI:inject()
        end)
        
        InGameMenuSettingsFrame.updateButtons = Utils.appendedFunction(InGameMenuSettingsFrame.updateButtons, function(frame)
            if self.WorkerSettingsUI then
                self.WorkerSettingsUI:ensureResetButton(frame)
            end
        end)
    end
    
    self.WorkerSettingsGUI = WorkerSettingsGUI.new()
    self.WorkerSettingsGUI:registerConsoleCommands()
    
    self.settings:load()
    
    return self
end

function WorkerManager:onMissionLoaded()
    if self.workerSystem then
        self.workerSystem:initialize()
    end
    
    if self.settings.enabled and self.settings.showNotifications then
        if g_currentMission and g_currentMission.hud then
            g_currentMission.hud:showBlinkingWarning(
                "Worker Costs Mod Active - Type 'workerCosts' for commands",
                4000
            )
        end
    end
end

function WorkerManager:update(dt)
    if self.workerSystem then
        self.workerSystem:update(dt)
    end
end

function WorkerManager:delete()
    if self.settings then
        self.settings:save()
    end
    
    print("Worker Costs Mod: Shutting down")
end