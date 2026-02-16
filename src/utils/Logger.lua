-- =========================================================
-- FS25 Worker Costs Mod - Logger
-- Version: 2.0.0
-- Last Updated: February 16, 2026
-- =========================================================
-- Centralized logging utility with module-specific loggers
-- and configurable log levels.
-- =========================================================
-- COPYRIGHT NOTICE:
-- All rights reserved. Unauthorized redistribution, copying,
-- or claiming this code as your own is strictly prohibited.
-- Original author: TisonK
-- =========================================================

---@class Logger
Logger = {}
Logger.__index = Logger

-- Singleton instance
local instance = nil

-- Log level constants (from Constants.LogLevel)
local LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    NONE = 5
}

---Get singleton instance
---@return Logger
function Logger.getInstance()
    if instance == nil then
        instance = {}
        setmetatable(instance, Logger)
        instance.level = LogLevel.INFO
        instance.modules = {}
        instance.prefix = "[WorkerCosts]"
    end
    return instance
end

---Set global log level
---@param level number LogLevel constant
function Logger:setLevel(level)
    self.level = level or LogLevel.INFO
end

---Get current log level
---@return number
function Logger:getLevel()
    return self.level
end

---Create a module-specific logger
---@param moduleName string
---@return ModuleLogger
function Logger:createModuleLogger(moduleName)
    if self.modules[moduleName] then
        return self.modules[moduleName]
    end

    local moduleLogger = ModuleLogger.new(self, moduleName)
    self.modules[moduleName] = moduleLogger
    return moduleLogger
end

---Log a message at specified level
---@param level number
---@param levelName string
---@param moduleName string|nil
---@param message string
---@param ... any Additional format arguments
function Logger:log(level, levelName, moduleName, message, ...)
    if level < self.level then
        return
    end

    local prefix = self.prefix
    if moduleName then
        prefix = string.format("%s[%s]", prefix, moduleName)
    end

    local formattedMessage
    if select("#", ...) > 0 then
        formattedMessage = string.format(message, ...)
    else
        formattedMessage = tostring(message)
    end

    local fullMessage = string.format("%s [%s] %s", prefix, levelName, formattedMessage)

    -- Use appropriate FS25 logging function
    if level >= LogLevel.ERROR then
        Logging.error(fullMessage)
    elseif level >= LogLevel.WARN then
        Logging.warning(fullMessage)
    else
        print(fullMessage)
    end
end

---Log debug message
---@param message string
---@param ... any
function Logger:debug(message, ...)
    self:log(LogLevel.DEBUG, "DEBUG", nil, message, ...)
end

---Log info message
---@param message string
---@param ... any
function Logger:info(message, ...)
    self:log(LogLevel.INFO, "INFO", nil, message, ...)
end

---Log warning message
---@param message string
---@param ... any
function Logger:warn(message, ...)
    self:log(LogLevel.WARN, "WARN", nil, message, ...)
end

---Log error message
---@param message string
---@param ... any
function Logger:error(message, ...)
    self:log(LogLevel.ERROR, "ERROR", nil, message, ...)
end

---============================================================================
--- ModuleLogger - Scoped logger for specific modules
---============================================================================

---@class ModuleLogger
ModuleLogger = {}
ModuleLogger.__index = ModuleLogger

---Create a new module logger
---@param logger Logger
---@param moduleName string
---@return ModuleLogger
function ModuleLogger.new(logger, moduleName)
    local self = setmetatable({}, ModuleLogger)
    self.logger = logger
    self.moduleName = moduleName
    return self
end

---Log debug message
---@param message string
---@param ... any
function ModuleLogger:debug(message, ...)
    self.logger:log(LogLevel.DEBUG, "DEBUG", self.moduleName, message, ...)
end

---Log info message
---@param message string
---@param ... any
function ModuleLogger:info(message, ...)
    self.logger:log(LogLevel.INFO, "INFO", self.moduleName, message, ...)
end

---Log warning message
---@param message string
---@param ... any
function ModuleLogger:warn(message, ...)
    self.logger:log(LogLevel.WARN, "WARN", self.moduleName, message, ...)
end

---Log error message
---@param message string
---@param ... any
function ModuleLogger:error(message, ...)
    self.logger:log(LogLevel.ERROR, "ERROR", self.moduleName, message, ...)
end

---Log info message (alias for consistency)
---@param message string
---@param ... any
function ModuleLogger:log(message, ...)
    self:info(message, ...)
end

return Logger
