-- =========================================================
-- FS25 Worker Costs Mod (version 1.0.0.6)
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
    self.workerHours = {}  -- Track hours worked per worker
    self.workerHectares = {}  -- Track hectares worked per worker
    self.lastUpdateTime = 0
    self.paymentInterval = 300000  -- 5 in-game minutes (in milliseconds)
    self.lastPaymentTime = 0
    self.isInitialized = false
    
    return self
end

function WorkerSystem:initialize()
    if self.isInitialized then
        return
    end
    
    if g_currentMission and g_currentMission.environment then
        self.lastUpdateTime = g_currentMission.environment.dayTime
        self.lastPaymentTime = g_currentMission.environment.dayTime
        
        self.isInitialized = true
        self:log("Worker System initialized successfully")
        self:log("Mode: %s, Base Rate: $%d", self.settings:getCostModeName(), self.settings:getWageRate())
        
        if self.settings.enabled and self.settings.showNotifications then
            self:showNotification("Worker Costs Mod Active", "Workers will charge wages")
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

function WorkerSystem:getActiveWorkers()
    local workers = {}
    
    if not g_currentMission or not g_currentMission.aiSystem then
        return workers
    end
    
    -- Get all active AI jobs
    for _, job in pairs(g_currentMission.aiSystem.activeJobs) do
        if job and job.isActive and job.vehicle then
            table.insert(workers, {
                vehicle = job.vehicle,
                job = job,
                name = job.vehicle:getFullName() or "Worker"
            })
        end
    end
    
    return workers
end

function WorkerSystem:calculateWorkerWage(worker, hoursWorked, hectaresWorked)
    local baseRate = self.settings:getWageRate()
    
    -- Apply skill multiplier (0.8x to 1.2x based on skill level)
    local skillMultiplier = 1.0
    
    -- Try to get skill from worker/job
    if worker.job and worker.job.getSkillLevel then
        local skill = worker.job:getSkillLevel() or 0.5
        skillMultiplier = 0.8 + (skill * 0.4) -- Range: 0.8 to 1.2
    end
    
    local wage = 0
    if self.settings.costMode == Settings.COST_MODE_HOURLY then
        wage = baseRate * hoursWorked * skillMultiplier
    else
        wage = baseRate * hectaresWorked * skillMultiplier
    end
    
    return math.floor(wage)
end

function WorkerSystem:chargeWage(workerName, amount, workType)
    if not g_currentMission then
        self:log("Cannot charge wage: No mission")
        return false
    end
    
    if amount <= 0 then
        self:log("Cannot charge wage: Amount is zero or negative")
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
        local message = string.format("%s - %s: -%s", workerName, modeText, formattedAmount)
        
        self:showNotification("Worker Payment", message)
    end
    
    self:log("%s %s wage: $%d from farm %d", workerName, workType, amount, farmId)
    return true
end

function WorkerSystem:update(dt)
    if not self.settings.enabled or not self.isInitialized then
        return
    end
    
    if not g_currentMission or not g_currentMission.environment then
        return
    end
    
    local currentTime = g_currentMission.environment.dayTime
    
    -- Track worker hours
    local activeWorkers = self:getActiveWorkers()
    
    for _, worker in ipairs(activeWorkers) do
        local vehicleId = tostring(worker.vehicle)
        
        -- Initialize tracking for new workers
        if not self.workerHours[vehicleId] then
            self.workerHours[vehicleId] = 0
            self.workerHectares[vehicleId] = 0
            self:log("Started tracking worker: %s", worker.name)
        end
        
        -- Calculate time worked (convert from milliseconds to hours)
        local timeDelta = currentTime - self.lastUpdateTime
        if timeDelta > 0 then
            local hoursWorked = timeDelta / 3600000  -- Convert ms to hours
            self.workerHours[vehicleId] = self.workerHours[vehicleId] + hoursWorked
            
            -- Try to track hectares if possible
            if worker.job and worker.job.getLastHa then
                local hectares = worker.job:getLastHa() or 0
                self.workerHectares[vehicleId] = self.workerHectares[vehicleId] + hectares
            end
        end
    end
    
    self.lastUpdateTime = currentTime
    
    -- Check if it's time to pay workers (every 5 in-game minutes)
    local timeSinceLastPayment = currentTime - self.lastPaymentTime
    if timeSinceLastPayment >= self.paymentInterval then
        self:processWorkerPayments()
        self.lastPaymentTime = currentTime
    end
end

function WorkerSystem:processWorkerPayments()
    local activeWorkers = self:getActiveWorkers()
    local totalPaid = 0
    local workersCount = 0
    
    for _, worker in ipairs(activeWorkers) do
        local vehicleId = tostring(worker.vehicle)
        
        if self.workerHours[vehicleId] then
            local hoursWorked = self.workerHours[vehicleId]
            local hectaresWorked = self.workerHectares[vehicleId] or 0
            
            if hoursWorked > 0 or hectaresWorked > 0 then
                local wage = self:calculateWorkerWage(worker, hoursWorked, hectaresWorked)
                
                if wage > 0 then
                    self:chargeWage(worker.name, wage, self.settings:getCostModeName())
                    totalPaid = totalPaid + wage
                    workersCount = workersCount + 1
                    
                    -- Reset tracking for next payment period
                    self.workerHours[vehicleId] = 0
                    self.workerHectares[vehicleId] = 0
                end
            end
        end
    end
    
    if workersCount > 0 then
        self:log("Paid %d workers a total of $%d", workersCount, totalPaid)
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
        workerHours = self.workerHours,
        workerHectares = self.workerHectares,
        lastUpdateTime = self.lastUpdateTime,
        lastPaymentTime = self.lastPaymentTime
    }
end

function WorkerSystem:loadState(state)
    if state then
        self.workerHours = state.workerHours or {}
        self.workerHectares = state.workerHectares or {}
        self.lastUpdateTime = state.lastUpdateTime or 0
        self.lastPaymentTime = state.lastPaymentTime or 0
    end
end
