-- =========================================================
-- FS25 Worker Costs Mod (version 1.0.0.7)
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
    self.workerHours = {}      -- Track real hours worked per worker
    self.workerHectares = {}   -- Track hectares worked per worker
    -- FIX: Use real-time milliseconds (dt) for ALL timing, NOT environment.dayTime.
    -- dayTime is game-time and advances ~48x faster than real time at x1 speed,
    -- which caused wages to be charged ~20x too high.
    self.realTimeAccumulator = 0   -- real ms accumulated since last payment
    self.paymentInterval = 300000  -- 5 real-world minutes in real milliseconds
    self.isInitialized = false

    return self
end

function WorkerSystem:initialize()
    if self.isInitialized then
        return
    end

    if g_currentMission then
        self.realTimeAccumulator = 0

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

    if not g_currentMission then
        return
    end

    -- dt is real elapsed milliseconds this frame. Using it (instead of
    -- environment.dayTime) means wages scale with real time regardless of
    -- the in-game time-speed setting, which fixes the ~20x overcharge bug.
    local activeWorkers = self:getActiveWorkers()

    -- Accumulate real hours worked per active worker this frame.
    -- 1 real hour = 3,600,000 real ms.
    local realHoursThisFrame = dt / 3600000

    for _, worker in ipairs(activeWorkers) do
        local vehicleId = tostring(worker.vehicle)

        -- Initialize tracking for new workers
        if not self.workerHours[vehicleId] then
            self.workerHours[vehicleId] = 0
            self.workerHectares[vehicleId] = 0
            self:log("Started tracking worker: %s", worker.name)
        end

        self.workerHours[vehicleId] = self.workerHours[vehicleId] + realHoursThisFrame

        -- Track hectares if the job exposes them
        if worker.job and worker.job.getLastHa then
            local hectares = worker.job:getLastHa() or 0
            self.workerHectares[vehicleId] = self.workerHectares[vehicleId] + hectares
        end
    end

    -- Payment timer: fire every paymentInterval real milliseconds.
    -- Subtract rather than reset so we don't drift over time.
    self.realTimeAccumulator = self.realTimeAccumulator + dt
    if self.realTimeAccumulator >= self.paymentInterval then
        self:processWorkerPayments()
        self.realTimeAccumulator = self.realTimeAccumulator - self.paymentInterval
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
        realTimeAccumulator = self.realTimeAccumulator
    }
end

function WorkerSystem:loadState(state)
    if state then
        self.workerHours = state.workerHours or {}
        self.workerHectares = state.workerHectares or {}
        -- Restore accumulator so a mid-period reload doesn't reset the payment clock.
        -- Falls back to 0 gracefully when loading a save from the old version.
        self.realTimeAccumulator = state.realTimeAccumulator or 0
    end
end