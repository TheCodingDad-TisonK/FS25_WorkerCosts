-- =========================================================
-- FS25 Worker Costs Mod
-- WCAboutFrame.lua  -  Tab 4: About / Help
-- =========================================================
-- Author: TisonK
-- =========================================================

---@class WCAboutFrame
WCAboutFrame = {}
local WCAboutFrame_mt = Class(WCAboutFrame, TabbedMenuFrameElement)

function WCAboutFrame.new()
    local self = WCAboutFrame:superClass().new(nil, WCAboutFrame_mt)
    self.name      = "WCAboutFrame"
    self.className = "WCAboutFrame"
    return self
end

function WCAboutFrame:onGuiSetupFinished()
    WCAboutFrame:superClass().onGuiSetupFinished(self)
end

function WCAboutFrame:initialize()
    -- nothing extra needed at init time
end

function WCAboutFrame:onFrameOpen()
    WCAboutFrame:superClass().onFrameOpen(self)
    self:refresh()
end

function WCAboutFrame:onFrameClose()
    WCAboutFrame:superClass().onFrameClose(self)
end

function WCAboutFrame:refresh()
    -- Pay interval from workerSystem
    if self.txtPayInterval and g_WorkerManager and g_WorkerManager.workerSystem then
        local min = math.floor(g_WorkerManager.workerSystem.paymentInterval / 60000)
        self.txtPayInterval:setText(string.format("%d min", min))
    end

    -- Mod version from g_modManager
    if self.txtVersion then
        local version = "unknown"
        if g_modManager then
            local mod = g_modManager:getModByName("FS25_WorkerCostsMod")
            if mod and mod.version then
                version = mod.version
            end
        end
        self.txtVersion:setText(version)
    end
end
