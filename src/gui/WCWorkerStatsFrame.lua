-- =========================================================
-- FS25 Worker Costs Mod
-- WCWorkerStatsFrame.lua  -  Tab 3: Per-worker cost breakdown
-- =========================================================
-- Author: TisonK
-- =========================================================

---@class WCWorkerStatsFrame
WCWorkerStatsFrame = {}
local WCWorkerStatsFrame_mt = Class(WCWorkerStatsFrame, TabbedMenuFrameElement)

function WCWorkerStatsFrame.new()
    local self = WCWorkerStatsFrame:superClass().new(nil, WCWorkerStatsFrame_mt)
    self.name      = "WCWorkerStatsFrame"
    self.className = "WCWorkerStatsFrame"
    return self
end

function WCWorkerStatsFrame:onGuiSetupFinished()
    WCWorkerStatsFrame:superClass().onGuiSetupFinished(self)
end

function WCWorkerStatsFrame:initialize()
    -- nothing extra needed at init time
end

function WCWorkerStatsFrame:onFrameOpen()
    WCWorkerStatsFrame:superClass().onFrameOpen(self)
    self:refresh()
end

function WCWorkerStatsFrame:onFrameClose()
    WCWorkerStatsFrame:superClass().onFrameClose(self)
end

function WCWorkerStatsFrame:refresh()
    if g_WorkerManager == nil then return end
    local settings = g_WorkerManager.settings
    if settings == nil then return end

    if self.txtCostMode then
        self.txtCostMode:setText(settings:getCostModeName())
    end

    if self.txtWageLevel then
        self.txtWageLevel:setText(settings:getWageLevelName())
    end

    if self.txtPayInterval and g_WorkerManager.workerSystem then
        local min = math.floor(g_WorkerManager.workerSystem.paymentInterval / 60000)
        self.txtPayInterval:setText(string.format("%d min", min))
    end

    self:refreshLive()
end

function WCWorkerStatsFrame:refreshLive()
    if g_WorkerManager == nil then return end
    local ws       = g_WorkerManager.workerSystem
    local settings = g_WorkerManager.settings
    if ws == nil or settings == nil then return end

    local workers     = ws:getActiveWorkers()
    local workerCount = #workers
    local rate        = settings:getWageRate()
    local intervalHrs = ws.paymentInterval / 3600000
    local isHourly    = (settings.costMode == Settings.COST_MODE_HOURLY)

    -- Active worker count (big)
    if self.txtWorkerCount then
        self.txtWorkerCount:setText(tostring(workerCount))
    end

    -- Cost per worker per interval
    if self.txtCostPerWorker then
        if isHourly and workerCount > 0 then
            local costPer = math.floor(rate * intervalHrs)
            self.txtCostPerWorker:setText(g_i18n:formatMoney(costPer, 0, true, false))
        else
            self.txtCostPerWorker:setText("-")
        end
    end

    -- Total cost per interval
    if self.txtTotalCost then
        if isHourly and workerCount > 0 then
            local total = math.floor(rate * intervalHrs * workerCount)
            self.txtTotalCost:setText(g_i18n:formatMoney(total, 0, true, false))
        else
            self.txtTotalCost:setText("-")
        end
    end

    -- Per-worker breakdown list
    if self.txtWorkerList then
        if workerCount > 0 then
            local lines = {}
            for _, w in ipairs(workers) do
                local costStr
                if isHourly then
                    costStr = g_i18n:formatMoney(math.floor(rate * intervalHrs), 0, true, false)
                else
                    costStr = g_i18n:getText("wc_costmode_2")
                end
                table.insert(lines, w.name .. "   +" .. costStr)
            end
            self.txtWorkerList:setText(table.concat(lines, "\n"))
        else
            self.txtWorkerList:setText(g_i18n:getText("wc_no_workers"))
        end
    end
end
