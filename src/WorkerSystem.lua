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

---@class WorkerSystem
WorkerSystem = {}
local WorkerSystem_mt = Class(WorkerSystem)

function WorkerSystem.new(settings)
    local self = setmetatable({}, WorkerSystem_mt)
    self.settings = settings
    self.activeWorkers = {}
    self.workerHours = {}      -- accumulated real hours per vehicleId since last payment
    self.workerHectares = {}   -- accumulated hectares per vehicleId since last payment
    self.workerNames = {}      -- last-known display name per vehicleId (for dismissed workers)
    -- Use real-time dt for ALL timing, NOT environment.dayTime.
    -- dayTime advances ~48x faster than real time at speed x1, which caused
    -- wages to be ~20x too high before this fix.
    self.realTimeAccumulator = 0   -- real ms accumulated since last payment
    self.paymentInterval = 300000  -- 5 real-world minutes in real milliseconds
    self.isInitialized = false
    self._isProcessingPayment = false
    self._originalAddMoney = nil   -- stored so we can restore on delete
    self._hookedAddMoney = false

    return self
end

function WorkerSystem:initialize()
    if self.isInitialized then
        return
    end

    if g_currentMission then
        self.realTimeAccumulator = 0

        -- Disable the game's built-in worker cost deductions to prevent double-charging
        self:installGameHook()

        self.isInitialized = true
        self:log("Worker System initialized. Mode: %s, Base Rate: $%d",
            self.settings:getCostModeName(), self.settings:getWageRate())
    end
end

--- Restore the original addMoney function and mark the system as shut down.
-- Called by WorkerManager:delete() during mission unload.
function WorkerSystem:delete()
    if self._originalAddMoney and g_currentMission then
        g_currentMission.addMoney = self._originalAddMoney
    end
    self._originalAddMoney = nil
    self._hookedAddMoney = false
    self.isInitialized = false
    self:log("Worker System shut down")
end

--- Patch mission.addMoney to zero out the game's own worker-wage deductions.
-- We use _isProcessingPayment as a flag so that OUR payments still pass through.
-- Only negative addMoney calls are intercepted; positive calls are always allowed.
function WorkerSystem:installGameHook()
    if not g_currentMission then
        return
    end
    if self._hookedAddMoney then
        return
    end

    local mission = g_currentMission
    local originalAddMoney = mission.addMoney
    if not originalAddMoney then
        return
    end

    -- Capture self in the closure so the hook survives reassignment of any
    -- module-level variable and cleans up correctly via delete().
    local capturedSelf = self
    self._originalAddMoney = originalAddMoney

    mission.addMoney = function(missionObj, amount, farmId, moneyType, ...)
        -- Only intercept negative amounts while our mod is active.
        -- When _isProcessingPayment is true the call originated from chargeWage(),
        -- so we let it through.  All other negative calls are the game's own
        -- worker-wage deductions and should be suppressed.
        if capturedSelf.settings.enabled and amount < 0 then
            if not capturedSelf._isProcessingPayment then
                capturedSelf:log("Suppressed built-in worker payment: %d", amount)
                return
            end
        end
        return originalAddMoney(missionObj, amount, farmId, moneyType, ...)
    end

    self._hookedAddMoney = true
    self:log("Installed hook to suppress built-in worker costs")
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

    if not g_currentMission then
        return workers
    end

    local aiSystem = g_currentMission.aiSystem
    if not aiSystem or not aiSystem.activeJobs then
        return workers
    end

    for _, job in pairs(aiSystem.activeJobs) do
        if job and job.isActive and job.vehicle then
            -- getFullName may not exist on all vehicle types; guard the call
            local name = (job.vehicle.getFullName and job.vehicle:getFullName()) or "Worker"
            table.insert(workers, {
                vehicle = job.vehicle,
                job = job,
                name = name
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
        -- Per-hectare mode: fall back to 0 when no area was tracked.
        -- This can happen for implements that don't expose getLastHa().
        -- The caller checks wage > 0 before deducting, so free-work is the
        -- only consequence — but we log it so it's visible in debug mode.
        if hectaresWorked <= 0 then
            self:log("Per-hectare wage skipped for worker with 0 ha tracked (implement may not support getLastHa)")
        end
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

    -- Raise the flag so the hook knows this negative addMoney call is ours.
    -- Use pcall so the flag is always cleared even if addMoney throws.
    self._isProcessingPayment = true
    local ok, err = pcall(function()
        g_currentMission:addMoney(-amount, farmId, MoneyType.OTHER, false)
    end)
    self._isProcessingPayment = false

    if not ok then
        self:log("chargeWage: addMoney threw an error: %s", tostring(err))
        return false
    end

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

        -- Initialize tracking for newly-detected workers
        if not self.workerHours[vehicleId] then
            self.workerHours[vehicleId] = 0
            self.workerHectares[vehicleId] = 0
            self:log("Started tracking worker: %s", worker.name)
        end
        -- Always refresh the name so dismissed-worker payments use the latest value
        self.workerNames[vehicleId] = worker.name

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

    -- Build a set of currently-active vehicle IDs for the dismissed-worker check below
    local activeIds = {}
    for _, worker in ipairs(activeWorkers) do
        activeIds[tostring(worker.vehicle)] = true
    end

    -- Pay workers that are currently active
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
                end
            end

            -- Always reset so the next interval starts clean
            self.workerHours[vehicleId] = 0
            self.workerHectares[vehicleId] = 0
        end
    end

    -- Pay workers that were dismissed mid-interval (accumulated time but no longer active).
    -- Without this, any time worked since the last payment tick is silently lost.
    for vehicleId, hoursWorked in pairs(self.workerHours) do
        if not activeIds[vehicleId] and (hoursWorked > 0 or (self.workerHectares[vehicleId] or 0) > 0) then
            local hectaresWorked = self.workerHectares[vehicleId] or 0
            local baseRate = self.settings:getWageRate()
            local wage = 0
            if self.settings.costMode == Settings.COST_MODE_HOURLY then
                wage = math.floor(baseRate * hoursWorked)
            else
                wage = math.floor(baseRate * hectaresWorked)
            end

            if wage > 0 then
                local name = self.workerNames[vehicleId] or "Dismissed Worker"
                self:chargeWage(name, wage, self.settings:getCostModeName())
                totalPaid = totalPaid + wage
                workersCount = workersCount + 1
            end

            -- Remove stale entries to prevent unbounded table growth
            self.workerHours[vehicleId] = nil
            self.workerHectares[vehicleId] = nil
            self.workerNames[vehicleId] = nil
        end
    end

    if workersCount > 0 then
        self:log("Paid %d worker(s) a total of $%d", workersCount, totalPaid)
    end
end

function WorkerSystem:testPayment()
    -- chargeWage already handles the notification, so no extra call needed here
    return self:chargeWage("Test Worker", 100, "test")
end
