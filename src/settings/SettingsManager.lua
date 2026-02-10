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
---@class SettingsManager
SettingsManager = {}
local SettingsManager_mt = Class(SettingsManager)

SettingsManager.MOD_NAME = g_currentModName
SettingsManager.XMLTAG = "WorkerCostsManager"

SettingsManager.defaultConfig = {
    wageLevel = 2,
    
    enabled = true,
    debugMode = false,
    costMode = 1,
    showNotifications = true,
    customRate = 0
}

function SettingsManager.new()
    return setmetatable({}, SettingsManager_mt)
end

function SettingsManager:getSavegameXmlFilePath()
    if g_currentMission.missionInfo and g_currentMission.missionInfo.savegameDirectory then
        return ("%s/%s.xml"):format(g_currentMission.missionInfo.savegameDirectory, SettingsManager.MOD_NAME)
    end
    return nil
end

function SettingsManager:loadSettings(settingsObject)
    local xmlPath = self:getSavegameXmlFilePath()
    if xmlPath and fileExists(xmlPath) then
        local xml = XMLFile.load("wc_Config", xmlPath)
        if xml then
            settingsObject.wageLevel = xml:getInt(self.XMLTAG..".wageLevel", self.defaultConfig.wageLevel)
            
            settingsObject.enabled = xml:getBool(self.XMLTAG..".enabled", self.defaultConfig.enabled)
            settingsObject.debugMode = xml:getBool(self.XMLTAG..".debugMode", self.defaultConfig.debugMode)
            settingsObject.costMode = xml:getInt(self.XMLTAG..".costMode", self.defaultConfig.costMode)
            settingsObject.showNotifications = xml:getBool(self.XMLTAG..".showNotifications", self.defaultConfig.showNotifications)
            settingsObject.customRate = xml:getInt(self.XMLTAG..".customRate", self.defaultConfig.customRate)
            
            xml:delete()
            return
        end
    end
    settingsObject.wageLevel = self.defaultConfig.wageLevel
    settingsObject.enabled = self.defaultConfig.enabled
    settingsObject.debugMode = self.defaultConfig.debugMode
    settingsObject.costMode = self.defaultConfig.costMode
    settingsObject.showNotifications = self.defaultConfig.showNotifications
    settingsObject.customRate = self.defaultConfig.customRate
end

function SettingsManager:saveSettings(settingsObject)
    local xmlPath = self:getSavegameXmlFilePath()
    if not xmlPath then return end
    
    local xml = XMLFile.create("wc_Config", xmlPath, self.XMLTAG)
    if xml then
        xml:setInt(self.XMLTAG..".wageLevel", settingsObject.wageLevel)
        
        xml:setBool(self.XMLTAG..".enabled", settingsObject.enabled)
        xml:setBool(self.XMLTAG..".debugMode", settingsObject.debugMode)
        xml:setInt(self.XMLTAG..".costMode", settingsObject.costMode)
        xml:setBool(self.XMLTAG..".showNotifications", settingsObject.showNotifications)
        xml:setInt(self.XMLTAG..".customRate", settingsObject.customRate)
        
        xml:save()
        xml:delete()
    end
end