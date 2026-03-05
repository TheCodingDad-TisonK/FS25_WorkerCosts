-- =========================================================
-- FS25 Worker Costs Mod
-- WCGui.lua  -  Inner TabbedMenu (Dashboard + Wage Settings)
-- =========================================================
-- Author: TisonK
-- =========================================================

local MOD_DIR = g_currentModDirectory

---@class WCGui
WCGui = {}
local WCGui_mt = Class(WCGui, TabbedMenu)

function WCGui.new(messageCenter, l18n, inputManager)
    local self = TabbedMenu.new(nil, WCGui_mt, messageCenter, l18n, inputManager)
    self.messageCenter = messageCenter
    self.l18n          = l18n
    self.inputManager  = g_inputBinding
    self._refreshTimer = 0
    return self
end

function WCGui:onGuiSetupFinished()
    WCGui:superClass().onGuiSetupFinished(self)

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)

    self.pageDashboard:initialize()
    self.pageWageSettings:initialize()
    self.pageWorkerStats:initialize()
    self.pageAbout:initialize()

    self:setupPages(self)
    self:setupMenuButtonInfo()
end

function WCGui:setupPages(gui)
    -- Pass a real icon .dds + full-tile UVs for each tab.
    -- Slice ID strings like "ingameMenu/tab_statistics" are NOT valid in FS25
    -- and produce "does not contain prefix or slice ID" warnings (see log).
    -- Using an explicit filename+UVs is the safe, warning-free approach.
    local fullUVs = GuiUtils.getUVs({ 0, 0, 1024, 1024 })

    local pages = {
        { gui.pageDashboard,    Utils.getFilename("icon.dds", MOD_DIR) },
        { gui.pageWageSettings, Utils.getFilename("icon.dds", MOD_DIR) },
        { gui.pageWorkerStats,  Utils.getFilename("icon.dds", MOD_DIR) },
        { gui.pageAbout,        Utils.getFilename("icon.dds", MOD_DIR) },
    }

    for idx, entry in ipairs(pages) do
        local page, iconFile = unpack(entry)
        gui:registerPage(page, idx)
        gui:addPageTab(page, iconFile, fullUVs)
    end

    gui:rebuildTabList()
end

function WCGui:setupMenuButtonInfo()
    local onBack = self.clickBackCallback

    self.defaultMenuButtonInfo = {
        {
            inputAction = InputAction.MENU_BACK,
            text        = g_i18n:getText("button_back"),
            callback    = onBack,
        },
    }
    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]
    self.defaultButtonActionCallbacks = { [InputAction.MENU_BACK] = onBack }
end

function WCGui:update(dt)
    WCGui:superClass().update(self, dt)
    self._refreshTimer = self._refreshTimer + dt
    if self._refreshTimer >= 500 then
        self._refreshTimer = 0
        if self.pageDashboard and self.pageDashboard.refreshLive then
            self.pageDashboard:refreshLive()
        end
        if self.pageWorkerStats and self.pageWorkerStats.refreshLive then
            self.pageWorkerStats:refreshLive()
        end
    end
end

function WCGui:onOpen()
    WCGui:superClass().onOpen(self)
    self._refreshTimer = 0
    self.pageDashboard:refresh()
    self.pageWageSettings:refresh()
    self.pageWorkerStats:refresh()
    self.pageAbout:refresh()
end

function WCGui:onClose()
    WCGui:superClass().onClose(self)
end

function WCGui:onButtonBack()
    self:exitMenu()
end

function WCGui:onClickBack()
    self:exitMenu()
end

function WCGui:exitMenu()
    self:changeScreen()
end
