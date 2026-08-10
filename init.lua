hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

local function loadConfig()
    local externalPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    local localPath = hs.fs.pathToAbsolute(hs.configdir .. "/private/config.lua")
    local configPath = externalPath or localPath

    if not configPath then
        return {}
    end

    local config = dofile(configPath)
    if type(config) ~= "table" then
        error("Hammerspoon config must return a table: " .. configPath)
    end
    return config
end

local config = loadConfig()
local hotkeys = config.hotkeys or {}
hammerspoon_theme = config.theme == "light" and "light" or "dark"
hammerspoon_opacity = tonumber(config.opacity) or 0.75
hammerspoon_opacity = math.min(math.max(hammerspoon_opacity, 0), 1)
local reloadNoticeKey = "hammerspoon.reloadNotice"
local supervisorEnabled = false

if hs.settings.get(reloadNoticeKey) then
    hs.settings.clear(reloadNoticeKey)
    hs.alert.show("配置已重新加载")
end

local function reloadConfig()
    hs.settings.set(reloadNoticeKey, true)
    hs.reload()
end

local function toggleSupervisor()
    if supervisorEnabled then
        spoon.ModalMgr.supervisor:exit()
        supervisorEnabled = false
        hs.alert.show("快捷键已停用")
    else
        spoon.ModalMgr.supervisor:enter()
        supervisorEnabled = true
        hs.alert.show("快捷键已启用")
    end
end

local function hotkey(name, fallback)
    return hotkeys[name] == nil and fallback or hotkeys[name]
end

local function hasHotkey(keys)
    return keys and keys[1] and keys[2] and string.len(keys[2]) > 0
end

local function bindSupervisor(keys, label, fn)
    if hasHotkey(keys) then
        spoon.ModalMgr.supervisor:bind(keys[1], keys[2], label, fn)
    end
end

local supervisorKeys = hotkey("supervisor", {{"cmd", "shift", "ctrl"}, "P"})
local helpKeys = hotkey("help", {{"alt", "shift"}, "/"})
hsupervisor_keys = supervisorKeys
hshelp_keys = helpKeys

local reloadKeys = hotkey("reload", {{"cmd", "shift", "ctrl"}, "R"})
if hasHotkey(reloadKeys) then
    hs.hotkey.bind(reloadKeys[1], reloadKeys[2], "重新加载配置", reloadConfig)
end

hs.loadSpoon("ModalMgr")
hs.hotkey.bind(supervisorKeys[1], supervisorKeys[2], "切换全部快捷键", toggleSupervisor)

for _, name in ipairs(config.spoons or {"KSheet", "WinWin"}) do
    hs.loadSpoon(name)
end

if spoon.BrightnessControl then
    spoon.BrightnessControl:bindHotkeys(config.brightness or {
        zero = {{"ctrl", "shift"}, "f1"},
        normal = {{"ctrl", "shift"}, "f2"},
    })
end

local actionHandlers = {
    toggleSupervisor = function()
        toggleSupervisor()
    end,
    showCheatsheet = function()
        if not spoon.KSheet then
            return
        end
        spoon.KSheet:show()
        spoon.ModalMgr:deactivateAll()
        spoon.ModalMgr:activate({"cheatsheetM"})
    end,
    openConsole = function()
        hs.toggleConsole()
    end,
    lockScreen = function()
        hs.caffeinate.lockScreen()
    end,
    insertCurrentTime = function()
        hs.eventtap.keyStrokes(os.date("%Y-%m-%d %H:%M:%S"))
    end,
    pasteChromeMarkdown = function()
        local app = hs.application.frontmostApplication()
        if not app or app:bundleID() ~= "com.google.Chrome" then
            return
        end

        local ok, data = hs.applescript('tell application "Google Chrome" to get {URL, title} of active tab of window 1')
        if ok then
            hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")")
        end
    end,
}

local actionsByID = {}
for _, action in ipairs(config.actions or {}) do
    actionsByID[action.id] = action
end

local function executeAction(action)
    if action.type == "function" then
        local handler = actionHandlers[action.name]
        if handler then
            handler()
        else
            print("Unknown action handler: " .. tostring(action.name))
        end
    elseif action.type == "text" then
        hs.eventtap.keyStrokes(action.text)
    elseif action.type == "execute" then
        hs.execute(action.command)
    elseif action.type == "url" then
        hs.urlevent.openURL(action.url)
    else
        print("Unknown action type: " .. tostring(action.type))
    end
end

spoon.ModalMgr:new("appM")
local appModal = spoon.ModalMgr.modal_list["appM"]
appModal:bind("", "escape", "退出", function() spoon.ModalMgr:deactivate({"appM"}) end)
appModal:bind("", "Q", "退出", function() spoon.ModalMgr:deactivate({"appM"}) end)
appModal:bind("", "L", "启动台", function()
    hs.spaces.toggleLaunchPad()
    spoon.ModalMgr:deactivate({"appM"})
end)
appModal:bind("", "D", "显示桌面", function()
    hs.spaces.toggleShowDesktop()
    spoon.ModalMgr:deactivate({"appM"})
end)

for _, app in ipairs(config.apps or {
    {key = "f", name = "Finder"},
    {key = "s", name = "Safari"},
    {key = "t", name = "Terminal"},
}) do
    if app.id then
        local name = hs.application.nameForBundleID(app.id)
        if name then
            appModal:bind("", app.key, name, function()
                hs.application.launchOrFocusByBundleID(app.id)
                spoon.ModalMgr:deactivate({"appM"})
            end)
        end
    elseif app.name then
        appModal:bind("", app.key, app.name, function()
            hs.application.launchOrFocus(app.name)
            spoon.ModalMgr:deactivate({"appM"})
        end)
    end
end

bindSupervisor(hotkey("appModal", {"alt", "A"}), "进入应用启动模式", function()
    spoon.ModalMgr:deactivateAll()
    spoon.ModalMgr:activate({"appM"}, "#FFBD2E", true)
end)

spoon.ModalMgr:new("quickActionM")
local actionModal = spoon.ModalMgr.modal_list["quickActionM"]
actionModal:bind("", "escape", "退出", function() spoon.ModalMgr:deactivate({"quickActionM"}) end)
actionModal:bind("", "Q", "退出", function() spoon.ModalMgr:deactivate({"quickActionM"}) end)

for _, action in ipairs(config.actions or {}) do
    if action.key and action.type then
        actionModal:bind("", action.key, action.label or action.type, function()
            executeAction(action)
            spoon.ModalMgr:deactivate({"quickActionM"})
        end)
    end
end

bindSupervisor(hotkey("actionModal", {"alt", "Q"}), "进入通用动作模式", function()
    spoon.ModalMgr:deactivateAll()
    spoon.ModalMgr:activate({"quickActionM"}, "#2390FF", true)
end)

bindSupervisor(hotkey("documentation", {"alt", "cmd", "H"}), "查看 Hammerspoon 手册", function()
    hs.doc.hsdocs.forceExternalBrowser(true)
    hs.doc.hsdocs.moduleEntitiesInSidebar(true)
    hs.doc.hsdocs.help()
end)

bindSupervisor(hotkey("lock", {"alt", "cmd", "L"}), "锁屏", function()
    hs.caffeinate.lockScreen()
end)

if spoon.WinWin then
    spoon.ModalMgr:new("resizeM")
    local resizeModal = spoon.ModalMgr.modal_list["resizeM"]
    resizeModal:bind("", "escape", "退出", function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    resizeModal:bind("", "Q", "退出", function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    resizeModal:bind("", "tab", "键位提示", function() spoon.ModalMgr:toggleCheatsheet() end)

    resizeModal:bind("", "A", "向左移动", function() spoon.WinWin:stepMove("left") end, nil, function() spoon.WinWin:stepMove("left") end)
    resizeModal:bind("", "D", "向右移动", function() spoon.WinWin:stepMove("right") end, nil, function() spoon.WinWin:stepMove("right") end)
    resizeModal:bind("", "W", "向上移动", function() spoon.WinWin:stepMove("up") end, nil, function() spoon.WinWin:stepMove("up") end)
    resizeModal:bind("", "S", "向下移动", function() spoon.WinWin:stepMove("down") end, nil, function() spoon.WinWin:stepMove("down") end)

    resizeModal:bind("", "H", "左半屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfleft") end)
    resizeModal:bind("", "L", "右半屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfright") end)
    resizeModal:bind("", "K", "上半屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfup") end)
    resizeModal:bind("", "J", "下半屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfdown") end)

    resizeModal:bind("", "Y", "屏幕左上角", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNW") end)
    resizeModal:bind("", "O", "屏幕右上角", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNE") end)
    resizeModal:bind("", "U", "屏幕左下角", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSW") end)
    resizeModal:bind("", "I", "屏幕右下角", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSE") end)

    resizeModal:bind("", "F", "全屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen") end)
    resizeModal:bind("", "C", "居中", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center") end)
    resizeModal:bind("", "G", "左三分之二屏居中分屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("centermost") end)
    resizeModal:bind("", "Z", "展示显示", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("show") end)
    resizeModal:bind("", "V", "编辑显示", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("shows") end)
    resizeModal:bind("", "X", "二分之一居中分屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center-2") end)

    resizeModal:bind("", "=", "窗口放大", function() spoon.WinWin:moveAndResize("expand") end, nil, function() spoon.WinWin:moveAndResize("expand") end)
    resizeModal:bind("", "-", "窗口缩小", function() spoon.WinWin:moveAndResize("shrink") end, nil, function() spoon.WinWin:moveAndResize("shrink") end)

    resizeModal:bind("ctrl", "H", "向左收缩窗口", function() spoon.WinWin:stepResize("left") end, nil, function() spoon.WinWin:stepResize("left") end)
    resizeModal:bind("ctrl", "L", "向右扩展窗口", function() spoon.WinWin:stepResize("right") end, nil, function() spoon.WinWin:stepResize("right") end)
    resizeModal:bind("ctrl", "K", "向上收缩窗口", function() spoon.WinWin:stepResize("up") end, nil, function() spoon.WinWin:stepResize("up") end)
    resizeModal:bind("ctrl", "J", "向下收缩窗口", function() spoon.WinWin:stepResize("down") end, nil, function() spoon.WinWin:stepResize("down") end)

    resizeModal:bind("", "left", "窗口移至左边屏幕", function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("left") end)
    resizeModal:bind("", "right", "窗口移至右边屏幕", function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("right") end)
    resizeModal:bind("", "up", "窗口移至上边屏幕", function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("up") end)
    resizeModal:bind("", "down", "窗口移至下边屏幕", function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("down") end)
    resizeModal:bind("", "space", "窗口移至下一个屏幕", function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("next") end)
    resizeModal:bind("", "B", "撤销最后一个窗口操作", function() spoon.WinWin:undo() end)
    resizeModal:bind("", "R", "重做最后一个窗口操作", function() spoon.WinWin:redo() end)

    resizeModal:bind("", "[", "左三分之二屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("mostleft") end)
    resizeModal:bind("", "]", "右三分之二屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("mostright") end)
    resizeModal:bind("", ",", "左三分之一屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("lesshalfleft") end)
    resizeModal:bind("", ".", "中分之一屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("onethird") end)
    resizeModal:bind("", "/", "右三分之一屏", function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("lesshalfright") end)
    resizeModal:bind("", "t", "将光标移至所在窗口中心位置", function() spoon.WinWin:centerCursor() end)

    bindSupervisor(hotkey("resizeModal", {"alt", "R"}), "进入窗口管理模式", function()
        spoon.ModalMgr:deactivateAll()
        spoon.ModalMgr:activate({"resizeM"}, "#B22222")
    end)
end

if spoon.KSheet then
    spoon.ModalMgr:new("cheatsheetM")
    local cheatsheetModal = spoon.ModalMgr.modal_list["cheatsheetM"]
    cheatsheetModal:bind("", "escape", "退出", function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    cheatsheetModal:bind("", "Q", "退出", function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)

end

bindSupervisor(hotkey("console", false), "打开 Hammerspoon 控制台", actionHandlers.openConsole)

local function fastKeyStroke(modifiers, character)
    local event = require("hs.eventtap").event
    event.newKeyEvent(modifiers, string.lower(character), true):post()
    event.newKeyEvent(modifiers, string.lower(character), false):post()
end

local function bindRepeatingKey(modifiers, key, targetModifiers, targetKey)
    hs.hotkey.bind(
        modifiers,
        key,
        function() fastKeyStroke(targetModifiers, targetKey) end,
        nil,
        function() fastKeyStroke(targetModifiers, targetKey) end
    )
end

for _, mapping in ipairs({
    {key = "h", modifiers = {}, target = "left"},
    {key = ",", modifiers = {}, target = "down"},
    {key = "i", modifiers = {}, target = "up"},
    {key = "l", modifiers = {}, target = "right"},
    {key = "0", modifiers = {"cmd"}, target = "left"},
    {key = "4", modifiers = {"cmd"}, target = "right"},
    {key = "b", modifiers = {"alt"}, target = "left"},
    {key = "f", modifiers = {"alt"}, target = "right"},
    {key = "u", modifiers = {}, target = "pageup"},
    {key = "e", modifiers = {}, target = "pageup"},
    {key = "d", modifiers = {}, target = "pagedown"},
}) do
    bindRepeatingKey({"alt"}, mapping.key, mapping.modifiers, mapping.target)
end

for _, mapping in ipairs({
    {key = "h", modifiers = {"shift"}, target = "left"},
    {key = ",", modifiers = {"shift"}, target = "down"},
    {key = "i", modifiers = {"shift"}, target = "up"},
    {key = "l", modifiers = {"shift"}, target = "right"},
    {key = "0", modifiers = {"shift", "cmd"}, target = "left"},
    {key = "4", modifiers = {"shift", "cmd"}, target = "right"},
    {key = "b", modifiers = {"shift", "alt"}, target = "left"},
    {key = "f", modifiers = {"shift", "alt"}, target = "right"},
}) do
    bindRepeatingKey({"alt", "shift"}, mapping.key, mapping.modifiers, mapping.target)
end

bindRepeatingKey({"shift", "alt", "ctrl"}, "h", {"shift", "alt"}, "left")
bindRepeatingKey({"shift", "alt", "ctrl"}, "l", {"shift", "alt"}, "right")
bindRepeatingKey({"alt"}, "'", {}, "forwarddelete")

for _, alias in ipairs(config.globalAliases or {}) do
    local action = actionsByID[alias.action]
    if action then
        hs.hotkey.bind(alias.modifiers, alias.key, action.label, function()
            executeAction(action)
        end)
    else
        print("Unknown global action: " .. tostring(alias.action))
    end
end

spoon.ModalMgr.supervisor:enter()
