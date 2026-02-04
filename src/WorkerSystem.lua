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
---@class WorkerSystem
WorkerSystem = {}
local WorkerSystem_mt = Class(WorkerSystem)

function WorkerSystem.new(settings)
    local self = setmetatable({}, WorkerSystem_mt)
    self.settings = settings
    self.activeWorkers = {}
    self.lastMinuteCheck = -1
    self.isInitialized = false
    
    return self
end

function WorkerSystem:initialize()
    if self.isInitialized then
        return
    end
    
    if g_currentMission and g_currentMission.environment then
        self.lastMinuteCheck = math.floor(g_currentMission.environment.dayTime / 60000)
        
        self.isInitialized = true
        self:log("Worker System initialized successfully")
        self:log("Mode: %s, Base Rate: $%d", self.settings:getCostModeName(), self.settings:getWageRate())
        
        if self.settings.enabled and self.settings.showNotifications then
            self:showNotification("Worker Costs Mod Active", "Type 'workerCosts' for commands")
        end
    end
end

function WorkerSystem:log(msg, ...)
    if self.settings.debugMode then
        print(string.format("[Worker Costs] " .. msg, ...))
    end
end

function WorkerSystem:showNotification(title, message)
    if not g_currentMission or not self.settings.showNotifications then
        return
    end
    
    if g_currentMission.hud and g_currentMission.hud.showBlinkingWarning then
        g_currentMission.hud:showBlinkingWarning(message, 4000)
    end
    
    self:log("%s: %s", title, message)
end

function WorkerSystem:calculateWorkerWage(worker, hoursWorked, hectaresWorked)
    local baseRate = self.settings:getWageRate()
    
    -- Apply skill multiplier (0.8x to 1.2x based on skill level)
    local skillMultiplier = 1.0
    if worker.getSkillLevel then
        local skill = worker:getSkillLevel() or 1.0
        skillMultiplier = 0.8 + (skill * 0.4) -- Range: 0.8 to 1.2
    end
    
    if self.settings.costMode == Settings.COST_MODE_HOURLY then
        local wage = baseRate * hoursWorked * skillMultiplier
        return math.floor(wage)
    else
        local wage = baseRate * hectaresWorked * skillMultiplier
        return math.floor(wage)
    end
end

function WorkerSystem:chargeWage(workerName, amount, workType)
    if not g_currentMission then
        self:log("Cannot charge wage: No mission")
        return false
    end
    
    local farmId = g_currentMission:getFarmId()
    if not farmId then
        self:log("Cannot charge wage: No farm ID")
        return false
    end
    
    -- Charge negative amount (deduct from farm money)
    g_currentMission:addMoney(
        -amount,
        farmId,
        MoneyType.OTHER,
        false
    )
    
    if self.settings.showNotifications then
        local formattedAmount = g_i18n:formatMoney(amount, 0, true, true)
        local modeText = self.settings:getCostModeName()
        local message = string.format("%s wage: -$%s", modeText, formattedAmount)
        
        self:showNotification("Worker Payment", message)
        
        self:log("Notification shown: %s", message)
    end
    
    self:log("%s %s wage: $%d from farm %d", workerName, workType, amount, farmId)
    return true
end

function WorkerSystem:update(dt)
    if not self.settings.enabled or not self.isInitialized then
        return
    end
    
    if g_currentMission and g_currentMission.environment then
        local currentMinute = math.floor(g_currentMission.environment.dayTime / 60000)
        
        -- Check every 5 minutes for worker payments
        if currentMinute ~= self.lastMinuteCheck and currentMinute % 5 == 0 then
            self.lastMinuteCheck = currentMinute
            
            -- Check for active workers and charge wages
            self:checkWorkerWages()
        end
    end
end

function WorkerSystem:checkWorkerWages()
    -- This would check for active hired workers in the game
    -- For now, we'll simulate a test worker
    if self.settings.debugMode then
        self:log("Checking worker wages (simulated)")
        
        -- Simulate charging for one worker
        local amount = self.settings:getWageRate() * 5 -- 5 hours of work
        self:chargeWage("Test Worker", amount, "hourly")
    end
end

function WorkerSystem:testPayment()
    local amount = 100  -- Test amount
    local success = self:chargeWage("Test Worker", amount, "test")
    
    if success and self.settings.showNotifications then
        self:showNotification("Test Payment", "Worker wage test: -$100")
    end
    
    return success
end

function WorkerSystem:saveState()
    return {
        activeWorkers = self.activeWorkers,
        lastMinuteCheck = self.lastMinuteCheck
    }
end

function WorkerSystem:loadState(state)
    if state then
        self.activeWorkers = state.activeWorkers or {}
        self.lastMinuteCheck = state.lastMinuteCheck or -1
    end
end