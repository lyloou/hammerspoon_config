local obj = {}
obj.__index = obj

obj.name = "WinSwitcher"
obj.version = "0.1"
obj.author = "zuorn"
obj.license = "MIT"
obj.homepage = "https://github.com/zuorn/hammerspoon_config"

obj.uiPrefs = {
    showSelectedThumbnail = false,
    showTitles = true,
    thumbnailSize = 250,
    textSize = 16,
}

local unavailableIcon = hs.image.imageFromName("NSStopProgressTemplate")
local snapshotCache = {}
local snapshotTtl = 45
local titleGap = 1
local iconSizeRatio = 0.26
local iconBottomMargin = 3
local panelPadding = 8
local topPadding = 2
local bottomPadding = 4
local highlightPad = 4

function obj:init()
    self.modifierPrefetch = { alt = false }
    self.selectedAppPid = nil
    self.appWindowCounts = {}
    self.usingSelectedApp = false
    self:createSwitchers()
end

function obj:getSnapshot(windowId)
    if not windowId then
        return unavailableIcon
    end
    local cached = snapshotCache[windowId]
    local now = hs.timer.secondsSinceEpoch()
    if not cached or cached[2] + snapshotTtl < now then
        snapshotCache[windowId] = {
            hs.window.snapshotForID(windowId) or unavailableIcon,
            now,
        }
    end
    return snapshotCache[windowId][1]
end

function obj:getWindowTitle(win)
    return win:title() or " "
end

function obj:getAppTitle(win)
    local app = win:application()
    local name = (app and app:name()) or " "
    local count = app and self.appWindowCounts[app:pid()] or nil
    if count and count > 1 then
        return string.format("%s 「+%d」", name, count - 1)
    end
    return name
end

function obj:buildCrossAppWindows(wf)
    local seen = {}
    local windows = {}
    self.appWindowCounts = {}
    for _, win in ipairs(wf:getWindows(hs.window.filter.sortByFocusedLast)) do
        local app = win:application()
        if app then
            local pid = app:pid()
            self.appWindowCounts[pid] = (self.appWindowCounts[pid] or 0) + 1
            if not seen[pid] then
                seen[pid] = true
                table.insert(windows, win)
            end
        end
    end
    return windows
end

function obj:buildWindowsForAppPid(pid)
    local windows = {}
    if not pid then
        return windows
    end
    for _, win in ipairs(self.crossAppFilter:getWindows(hs.window.filter.sortByFocusedLast)) do
        local app = win:application()
        if app and app:pid() == pid then
            table.insert(windows, win)
        end
    end
    return windows
end

function obj:prefetch(sw, buildWindowsFn)
    if sw.selected then
        return
    end
    sw.windows = buildWindowsFn and buildWindowsFn() or sw.wf:getWindows(hs.window.filter.sortByFocusedLast)
    if not sw.ui.showThumbnails then
        return
    end
    for _, win in ipairs(sw.windows) do
        local windowId = win:id()
        hs.timer.doAfter(0, function()
            self:getSnapshot(windowId)
        end)
    end
end

function obj:clearPrefetch(sw)
    if not sw.selected then
        sw.windows = nil
    end
end

function obj:getActiveScreenFrame()
    local win = hs.window.focusedWindow()
    local screen = win and win:screen() or hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
    return screen:frame()
end

function obj:setScreenFrame(sw)
    sw.drawings.screenFrame = self:getActiveScreenFrame()
    sw.drawings.lastn = -1
end

function obj:dismissPanel(sw)
    local windows, drawings, ui = sw.windows, sw.drawings, sw.ui
    sw.windows = nil
    sw.selected = nil
    if sw.modsTimer then
        sw.modsTimer:stop()
        sw.modsTimer = nil
    end
    if sw.drawDelayed and sw.drawDelayed:running() then
        sw.drawDelayed:stop()
    end
    if not windows or not drawings then
        return
    end
    local haveThumbs, haveTitles = ui.showThumbnails, ui.showTitles
    drawings.background:hide()
    drawings.highlightRect:hide()
    for i = 1, #windows do
        local dr = drawings[i]
        if dr.icon then
            dr.icon:hide()
        end
        if haveThumbs and dr.thumb then
            dr.thumb:hide()
        end
        if haveTitles and dr.titleRect then
            dr.titleRect:hide()
            dr.titleText:hide()
        end
    end
    drawings.selRect:hide()
    if ui.showSelectedThumbnail then
        drawings.selThumb:hide()
        drawings.selIcon:hide()
    end
    if ui.showSelectedTitle then
        drawings.selTitleRect:hide()
        drawings.selTitleText:hide()
    end
end

function obj:adjustLayout(sw)
    local windows, drawings, ui = sw.windows, sw.drawings, sw.ui
    if not windows or not drawings then
        return
    end
    local nwindows = #windows
    local size = drawings.size
    if not size then
        return
    end
    local titleHeight = ui.showTitles and ui.titleHeight or 0
    local titleGapValue = ui.showTitles and titleGap or 0
    local hPad = panelPadding
    local screenFrame = drawings.screenFrame or self:getActiveScreenFrame()
    local bgH = topPadding + titleHeight + titleGapValue + size + bottomPadding
    local bgW = hPad + (size + hPad) * nwindows
    local bgframe = hs.geometry(0, 0, bgW, bgH):setcenter(screenFrame.center)
    drawings.background:setFrame(bgframe):setRoundedRectRadii(hPad, hPad)
    local iconSize = size * iconSizeRatio
    for i = 1, nwindows do
        local dr = drawings[i]
        local thumbFrame = hs.geometry(bgframe.x, bgframe.y, size, size)
            :move(hPad + (size + hPad) * (i - 1), topPadding + titleHeight + titleGapValue)
        if dr.thumb then
            dr.thumb:setFrame(thumbFrame)
        end
        if dr.icon then
            local iconFrame
            if ui.showThumbnails then
                iconFrame = hs.geometry.copy(thumbFrame)
                    :setw(iconSize)
                    :seth(iconSize)
                    :move((size - iconSize) / 2, size - iconSize - iconBottomMargin)
            else
                iconFrame = thumbFrame
            end
            dr.icon:setFrame(iconFrame)
        end
        if ui.showTitles then
            dr.titleFrame = hs.geometry(thumbFrame.x, thumbFrame.y - titleGapValue - titleHeight, thumbFrame.w, titleHeight)
        end
        local hp = highlightPad
        dr.highlightFrame = hs.geometry.copy(thumbFrame)
            :move(-hp, -hp - titleHeight - titleGapValue)
            :setw(size + hp * 2)
            :seth(size + hp * 2 + titleHeight + titleGapValue)
    end
    local selected = sw.selected
    if selected and drawings[selected] then
        drawings.highlightRect:setFrame(drawings[selected].highlightFrame)
    end
end

function obj:renderPanel(sw, getTitleFn)
    if sw.drawDelayed and sw.drawDelayed:running() then
        sw.drawDelayed:stop()
    end
    local windows, drawings, ui = sw.windows, sw.drawings, sw.ui
    if not windows or not drawings or not sw.selected then
        return
    end
    self:adjustLayout(sw)
    local haveThumbs, haveTitles = ui.showThumbnails, ui.showTitles
    local size = drawings.size
    drawings.background:show()
    drawings.highlightRect:show()
    for i = 1, #windows do
        local win, dr = windows[i], drawings[i]
        if haveThumbs and dr.thumb then
            dr.thumb:setImage(self:getSnapshot(win:id())):show()
        end
        if dr.icon then
            local app = win:application()
            local bundleId = app and app:bundleID()
            local icon = bundleId and hs.image.imageFromAppBundle(bundleId) or unavailableIcon
            dr.icon:setImage(icon):show()
        end
        if haveTitles and dr.titleRect and dr.titleFrame then
            local title = getTitleFn(win)
            local titleFrame = dr.titleFrame
            local titleWidth = hs.drawing.getTextDrawingSize(title, ui.titleTextStyle).w * 1.1
            if size and titleWidth < titleFrame.w then
                titleFrame = hs.geometry.copy(titleFrame):setw(titleWidth):move((size - titleWidth) / 2, 0)
            end
            dr.titleRect:setFrame(titleFrame):show()
            dr.titleText:setFrame(titleFrame):setText(title):show()
        end
    end
end

function obj:makeStepFns(sw, buildWindowsFn, getTitleFn)
    local function step(direction)
        self:setScreenFrame(sw)
        if buildWindowsFn then
            sw.windows = buildWindowsFn()
        end
        if direction > 0 then
            sw:next()
        else
            sw:previous()
        end
        self:renderPanel(sw, getTitleFn)
    end
    return function()
        step(1)
    end, function()
        step(-1)
    end
end

function obj:createSwitchers()
    self.windowFilter = hs.window.filter.new()
    self.windowFilter:setDefaultFilter({
        visible = true,
        activeApplication = true,
    })
    self.windowSwitcher = hs.window.switcher.new(self.windowFilter, self.uiPrefs)

    self.crossAppFilter = hs.window.filter.new()
    self.crossAppFilter:setCurrentSpace(true)
    self.crossAppFilter:setDefaultFilter({
        visible = true,
    })
    self.crossAppSwitcher = hs.window.switcher.new(self.crossAppFilter, self.uiPrefs)

    self.switchToNextWindow, self.switchToPreviousWindow = self:makeStepFns(
        self.windowSwitcher,
        nil,
        function(win)
            return self:getWindowTitle(win)
        end
    )
    self.switchToNextCrossAppWindow, self.switchToPreviousCrossAppWindow = self:makeStepFns(
        self.crossAppSwitcher,
        function()
            return self:buildCrossAppWindows(self.crossAppFilter)
        end,
        function(win)
            return self:getAppTitle(win)
        end
    )
end

function obj:getSelectedCrossAppPid()
    local selected = self.crossAppSwitcher.selected
    local windows = self.crossAppSwitcher.windows
    local win = selected and windows and windows[selected]
    local app = win and win:application()
    return app and app:pid() or nil
end

function obj:switchSelectedAppWindow(direction)
    local pid = self:getSelectedCrossAppPid()
    if pid then
        self.selectedAppPid = pid
        self.usingSelectedApp = true
        self:dismissPanel(self.crossAppSwitcher)
    elseif not self.windowSwitcher.selected then
        self.selectedAppPid = nil
        self.usingSelectedApp = false
    end
    if self.usingSelectedApp and self.selectedAppPid then
        self.windowSwitcher.windows = self:buildWindowsForAppPid(self.selectedAppPid)
    else
        self.selectedAppPid = nil
    end
    if direction > 0 then
        self.switchToNextWindow()
    else
        self.switchToPreviousWindow()
    end
end

function obj:startPrefetchTap()
    if self.prefetchTap then
        self.prefetchTap:stop()
    end
    self.prefetchTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
        local altDown = event:getFlags().alt
        if altDown and not self.modifierPrefetch.alt then
            self:prefetch(self.windowSwitcher, nil)
            self:prefetch(self.crossAppSwitcher, function()
                return self:buildCrossAppWindows(self.crossAppFilter)
            end)
        elseif not altDown and self.modifierPrefetch.alt then
            self.selectedAppPid = nil
            self.usingSelectedApp = false
            self:clearPrefetch(self.windowSwitcher)
            self:clearPrefetch(self.crossAppSwitcher)
        end
        self.modifierPrefetch.alt = altDown
        return false
    end)
    self.prefetchTap:start()
end

function obj:bindOne(keys, label, pressedFn)
    if keys and keys[2] and string.len(keys[2]) > 0 then
        hs.hotkey.bind(keys[1], keys[2], label, pressedFn, nil, pressedFn)
    end
end

function obj:bindHotkeys(mapping)
    if not self.windowSwitcher or not self.crossAppSwitcher then
        self:init()
    end
    mapping = mapping or {}
    self:bindOne(mapping.windowNext, "应用内下一窗口", function()
        self:switchSelectedAppWindow(1)
    end)
    self:bindOne(mapping.windowPrevious, "应用内上一窗口", function()
        self:switchSelectedAppWindow(-1)
    end)
    self:bindOne(mapping.crossAppNext, "跨应用下一窗口", self.switchToNextCrossAppWindow)
    self:bindOne(mapping.crossAppPrevious, "跨应用上一窗口", self.switchToPreviousCrossAppWindow)
    self:startPrefetchTap()
end

return obj
