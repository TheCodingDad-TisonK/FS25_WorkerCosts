-- =========================================================
-- FS25 Worker Costs Mod
-- WCWageSettingsFrame.lua  -  Tab 2: Wage Settings
-- =========================================================
-- Author: TisonK
-- =========================================================

---@class WCWageSettingsFrame
WCWageSettingsFrame = {}
local WCWageSettingsFrame_mt = Class(WCWageSettingsFrame, TabbedMenuFrameElement)

function WCWageSettingsFrame.new()
    local self = WCWageSettingsFrame:superClass().new(nil, WCWageSettingsFrame_mt)
    self.name      = "WCWageSettingsFrame"
    self.className = "WCWageSettingsFrame"
    return self
end

function WCWageSettingsFrame:onGuiSetupFinished()
    WCWageSettingsFrame:superClass().onGuiSetupFinished(self)
    self:bindCallbacks()
end

function WCWageSettingsFrame:initialize()
    -- nothing extra needed at init time
end

-- Wire up all the option widgets → settings
function WCWageSettingsFrame:bindCallbacks()
    -- Mod Enabled toggle
    if self.optEnabled then
        self.optEnabled.onClickCallback = function(state)
            if g_WorkerManager and g_WorkerManager.settings then
                g_WorkerManager.settings.enabled = (state == 2)
                g_WorkerManager.settings:save()
            end
        end
    end

    -- Cost Mode selector
    if self.optCostMode then
        self.optCostMode.onClickCallback = function(state)
            if g_WorkerManager and g_WorkerManager.settings then
                g_WorkerManager.settings:setCostMode(state)
                g_WorkerManager.settings:save()
                self:refreshRatePreview()
            end
        end
    end

    -- Wage Level selector
    if self.optWageLevel then
        self.optWageLevel.onClickCallback = function(state)
            if g_WorkerManager and g_WorkerManager.settings then
                g_WorkerManager.settings:setWageLevel(state)
                g_WorkerManager.settings:save()
                self:refreshRatePreview()
            end
        end
    end

    -- Notifications toggle
    if self.optNotifications then
        self.optNotifications.onClickCallback = function(state)
            if g_WorkerManager and g_WorkerManager.settings then
                g_WorkerManager.settings.showNotifications = (state == 2)
                g_WorkerManager.settings:save()
            end
        end
    end

    -- Debug mode toggle
    if self.optDebugMode then
        self.optDebugMode.onClickCallback = function(state)
            if g_WorkerManager and g_WorkerManager.settings then
                g_WorkerManager.settings.debugMode = (state == 2)
                g_WorkerManager.settings:save()
            end
        end
    end

    -- Monthly salary dialog toggle
    if self.optMonthlySalary then
        self.optMonthlySalary.onClickCallback = function(state)
            if g_WorkerManager and g_WorkerManager.settings then
                g_WorkerManager.settings.monthlySalaryEnabled = (state == 2)
                g_WorkerManager.settings:save()
            end
        end
    end
end

function WCWageSettingsFrame:onFrameOpen()
    WCWageSettingsFrame:superClass().onFrameOpen(self)
    self:refresh()
end

function WCWageSettingsFrame:onFrameClose()
    WCWageSettingsFrame:superClass().onFrameClose(self)
end

-- Sync all widgets to current settings values
function WCWageSettingsFrame:refresh()
    if g_WorkerManager == nil then return end
    local settings = g_WorkerManager.settings
    if settings == nil then return end

    if self.optEnabled and self.optEnabled.setState then
        self.optEnabled:setState(settings.enabled and 2 or 1)
    end

    if self.optCostMode then
        if self.optCostMode.setTexts then
            self.optCostMode:setTexts({
                g_i18n:getText("wc_costmode_1"),
                g_i18n:getText("wc_costmode_2"),
            })
        end
        if self.optCostMode.setState then
            self.optCostMode:setState(settings.costMode)
        end
    end

    if self.optWageLevel then
        if self.optWageLevel.setTexts then
            self.optWageLevel:setTexts({
                g_i18n:getText("wc_diff_1"),
                g_i18n:getText("wc_diff_2"),
                g_i18n:getText("wc_diff_3"),
            })
        end
        if self.optWageLevel.setState then
            self.optWageLevel:setState(settings.wageLevel)
        end
    end

    if self.optNotifications and self.optNotifications.setState then
        self.optNotifications:setState(settings.showNotifications and 2 or 1)
    end

    if self.optDebugMode and self.optDebugMode.setState then
        self.optDebugMode:setState(settings.debugMode and 2 or 1)
    end

    -- Monthly salary dialog toggle (widget is optional — XML may not include it yet)
    if self.optMonthlySalary and self.optMonthlySalary.setState then
        self.optMonthlySalary:setState(settings.monthlySalaryEnabled and 2 or 1)
    end

    self:refreshRatePreview()
end

-- Update the live "effective rate" preview text
function WCWageSettingsFrame:refreshRatePreview()
    if g_WorkerManager == nil then return end
    local settings = g_WorkerManager.settings
    if settings == nil then return end

    local rate = settings:getWageRate()

    if self.txtBigRate then
        if settings.costMode == Settings.COST_MODE_HOURLY then
            self.txtBigRate:setText(string.format("$%d / h", rate))
        else
            self.txtBigRate:setText(string.format("$%d / ha", rate))
        end
    end

    if self.txtRateLabel then
        self.txtRateLabel:setText(settings:getWageLevelName())
    end

    if self.txtPayInterval and g_WorkerManager.workerSystem then
        local ms  = g_WorkerManager.workerSystem.paymentInterval
        local min = math.floor(ms / 60000)
        self.txtPayInterval:setText(string.format("%d min", min))
    end
end

-- Reset button callback (wired from XML onClick)
function WCWageSettingsFrame:onClickReset()
    if g_WorkerManager and g_WorkerManager.settings then
        g_WorkerManager.settings:resetToDefaults()
        self:refresh()
        Logging.info("WCWageSettingsFrame: Settings reset to defaults.")
    end
end

function WCWageSettingsFrame:onBtnResetFocus()
    if self.btnResetBg then
        self.btnResetBg:setImageColor(0.50, 0.16, 0.16, 0.95)
    end
end

function WCWageSettingsFrame:onBtnResetLeave()
    if self.btnResetBg then
        self.btnResetBg:setImageColor(0.35, 0.12, 0.12, 0.95)
    end
end
