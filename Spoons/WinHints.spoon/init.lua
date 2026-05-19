local obj = {}
obj.__index = obj

obj.name = "WinHints"
obj.version = "0.1"
obj.author = "zuorn"
obj.license = "MIT"
obj.homepage = "https://github.com/zuorn/hammerspoon_config"

obj.hintChars = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

local unavailableIcon = hs.image.imageFromName("NSStopProgressTemplate")

local ui = {
    cardW = 680,
    cardH = 58,
    minCardW = 360,
    minCardH = 44,
    gap = 8,
    padding = 20,
    hintW = 46,
    hintH = 28,
    iconSize = 28,
    bgColor = {red=0.08, green=0.08, blue=0.08, alpha=0.88},
    cardColor = {red=0.18, green=0.18, blue=0.18, alpha=0.96},
    titleColor = {red=1, green=1, blue=1, alpha=0.95},
    hintColor = {red=0.95, green=0.52, blue=0.14, alpha=1},
    hintTextColor = {red=1, green=1, blue=1, alpha=1},
}

function obj:init()
    self.drawings = {}
    self.windowsByHint = {}
    self.prefix = ""
    self.modal = nil
    self.windowFilter = hs.window.filter.new()
    self.windowFilter:setCurrentSpace(true)
    self.windowFilter:setDefaultFilter({
        visible = true,
    })
end

function obj:getActiveScreen()
    local win = hs.window.focusedWindow()
    return (win and win:screen()) or hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
end

function obj:getWindows()
    local windows = {}
    for _, win in ipairs(self.windowFilter:getWindows(hs.window.filter.sortByFocusedLast)) do
        local app = win:application()
        if app and win:isStandard() then
            table.insert(windows, win)
        end
    end
    return windows
end

function obj:hintForIndex(index)
    local base = #self.hintChars
    local hint = ""
    local n = index
    repeat
        local rem = (n - 1) % base
        hint = self.hintChars[rem + 1] .. hint
        n = math.floor((n - 1) / base)
    until n == 0
    return hint
end

function obj:fitLayout(count, frame)
    local maxW = math.max(1, frame.w - ui.padding * 2)
    local maxH = math.max(1, frame.h - ui.padding * 2)
    local cols = 1
    local rows = count
    local cardW = math.max(ui.minCardW, math.min(ui.cardW, maxW))
    local cardH = math.max(ui.minCardH, math.min(ui.cardH, (maxH - ui.gap * (rows - 1)) / rows))
    return cols, rows, cardW, cardH
end

function obj:makeText(frame, text, size, color, align)
    return hs.drawing.text(frame, text):setTextStyle({
        font = ".AppleSystemUIFont",
        size = size,
        color = color,
        alignment = align or "left",
        lineBreak = "truncateTail",
    })
end

function obj:drawWindow(win, hint, frame)
    local card = hs.drawing.rectangle(frame)
        :setFillColor(ui.cardColor)
        :setStrokeColor({red=1, green=1, blue=1, alpha=0.08})
        :setStrokeWidth(1)
        :setRoundedRectRadii(8, 8)
        :show()

    local contentY = frame.y + (frame.h - ui.hintH) / 2
    local hintFrame = hs.geometry(frame.x + 10, contentY, ui.hintW, ui.hintH)
    local hintRect = hs.drawing.rectangle(hintFrame)
        :setFillColor(ui.hintColor)
        :setStrokeColor({red=1, green=1, blue=1, alpha=0.7})
        :setStrokeWidth(1)
        :setRoundedRectRadii(6, 6)
        :show()
    local hintText = self:makeText(hintFrame, hint, 17, ui.hintTextColor, "center"):show()

    local app = win:application()
    local bundleId = app and app:bundleID()
    local icon = (bundleId and hs.image.imageFromAppBundle(bundleId)) or unavailableIcon
    local iconFrame = hs.geometry(hintFrame.x2 + 10, frame.y + (frame.h - ui.iconSize) / 2, ui.iconSize, ui.iconSize)
    local iconDrawing = hs.drawing.image(iconFrame, icon):show()

    local title = win:title()
    if not title or title == "" then
        title = app and app:name() or " "
    end
    local titleFrame = hs.geometry(iconFrame.x2 + 10, frame.y + (frame.h - 24) / 2, frame.x2 - iconFrame.x2 - 18, 24)
    local titleText = self:makeText(titleFrame, title, 15, ui.titleColor, "left"):show()

    table.insert(self.drawings, card)
    table.insert(self.drawings, hintRect)
    table.insert(self.drawings, hintText)
    table.insert(self.drawings, iconDrawing)
    table.insert(self.drawings, titleText)
end

function obj:draw(windows)
    local screen = self:getActiveScreen()
    local frame = screen:frame()
    local cols, rows, cardW, cardH = self:fitLayout(#windows, frame)
    local panelW = ui.padding * 2 + cols * cardW + (cols - 1) * ui.gap
    local panelH = ui.padding * 2 + rows * cardH + (rows - 1) * ui.gap
    local panelFrame = hs.geometry(0, 0, panelW, panelH):setcenter(frame.center)

    local background = hs.drawing.rectangle(panelFrame)
        :setFillColor(ui.bgColor)
        :setStroke(false)
        :setRoundedRectRadii(10, 10)
        :show()
    table.insert(self.drawings, background)

    for i, win in ipairs(windows) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local hint = self:hintForIndex(i)
        self.windowsByHint[hint] = win
        local cardFrame = hs.geometry(
            panelFrame.x + ui.padding + col * (cardW + ui.gap),
            panelFrame.y + ui.padding + row * (cardH + ui.gap),
            cardW,
            cardH
        )
        self:drawWindow(win, hint, cardFrame)
    end
end

function obj:bindModal()
    self.modal = hs.hotkey.modal.new(nil, nil)
    self.modal:bind({}, "escape", function()
        self:hide()
    end)
    self.modal:bind({}, "delete", function()
        self.prefix = ""
    end)
    for _, c in ipairs(self.hintChars) do
        self.modal:bind({}, c, function()
            self:processChar(c)
        end)
    end
end

function obj:processChar(char)
    self.prefix = self.prefix .. char
    local exact = self.windowsByHint[self.prefix]
    if exact then
        self:hide()
        exact:focus()
        return
    end
    local hasPrefix = false
    for hint, _ in pairs(self.windowsByHint) do
        if string.sub(hint, 1, string.len(self.prefix)) == self.prefix then
            hasPrefix = true
            break
        end
    end
    if not hasPrefix then
        self.prefix = char
        if self.windowsByHint[self.prefix] then
            local win = self.windowsByHint[self.prefix]
            self:hide()
            win:focus()
        end
    end
end

function obj:hide()
    if self.modal then
        self.modal:exit()
        self.modal = nil
    end
    for _, drawing in ipairs(self.drawings) do
        drawing:delete()
    end
    self.drawings = {}
    self.windowsByHint = {}
    self.prefix = ""
end

function obj:show()
    if not self.windowFilter then
        self:init()
    end
    self:hide()
    local windows = self:getWindows()
    if #windows == 0 then
        return
    end
    self:draw(windows)
    self:bindModal()
    self.modal:enter()
end

return obj
