-- =========================================================
-- FS25 Worker Costs Mod - IWageStrategy Interface
-- Version: 2.0.0
-- Last Updated: February 11, 2026
-- =========================================================
-- Strategy interface for wage calculation algorithms.
-- Allows pluggable wage calculation methods.
-- =========================================================
-- COPYRIGHT NOTICE:
-- All rights reserved. Unauthorized redistribution, copying,
-- or claiming this code as your own is strictly prohibited.
-- Original author: TisonK
-- =========================================================

---@class IWageStrategy
IWageStrategy = {}

---============================================================================
--- Strategy Interface
---============================================================================

---Calculate wage for a worker
---@param worker Worker
---@param policy WagePolicy
---@param hoursWorked number
---@param hectaresWorked number
---@return number
function IWageStrategy:calculate(worker, policy, hoursWorked, hectaresWorked)
    error("IWageStrategy.calculate not implemented")
end

---Get strategy name
---@return string
function IWageStrategy:getName()
    error("IWageStrategy.getName not implemented")
end

---Get strategy description
---@return string
function IWageStrategy:getDescription()
    error("IWageStrategy.getDescription not implemented")
end

---============================================================================
--- Hourly Strategy Implementation
---============================================================================

---@class HourlyWageStrategy : IWageStrategy
HourlyWageStrategy = {}

function HourlyWageStrategy:calculate(worker, policy, hoursWorked, hectaresWorked)
    return policy.baseRate * hoursWorked
end

function HourlyWageStrategy:getName()
    return "Hourly"
end

function HourlyWageStrategy:getDescription()
    return "Pay workers per hour of work"
end

---============================================================================
--- Per Hectare Strategy Implementation
---============================================================================

---@class PerHectareWageStrategy : IWageStrategy
PerHectareWageStrategy = {}

function PerHectareWageStrategy:calculate(worker, policy, hoursWorked, hectaresWorked)
    return policy.baseRate * hectaresWorked
end

function PerHectareWageStrategy:getName()
    return "Per Hectare"
end

function PerHectareWageStrategy:getDescription()
    return "Pay workers per hectare of work completed"
end

---============================================================================
--- Hybrid Strategy Implementation
---============================================================================

---@class HybridWageStrategy : IWageStrategy
HybridWageStrategy = {}

function HybridWageStrategy:calculate(worker, policy, hoursWorked, hectaresWorked)
    -- 70% based on time, 30% based on area
    local timeComponent = policy.baseRate * hoursWorked * 0.7
    local areaComponent = policy.baseRate * hectaresWorked * 0.3
    return (timeComponent + areaComponent)
end

function HybridWageStrategy:getName()
    return "Hybrid"
end

function HybridWageStrategy:getDescription()
    return "70% hourly + 30% per hectare"
end

return {
    Hourly = HourlyWageStrategy,
    PerHectare = PerHectareWageStrategy,
    Hybrid = HybridWageStrategy
}