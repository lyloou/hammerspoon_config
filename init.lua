----------------------------------------------------------------------------------------------------

-- author: zuorn
-- mail: zuorn@qq.com
-- github: https://github.com/zuorn/hammerspoon_config

----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

----------------------------------------------------------------------------------------------------
------------------------------------------ 配置设置 -------------------------------------------------
-- 配置文件
-- 使用自定义配置 （如果存在的话）
----------------------------------------------------------------------------------------------------
custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')
if custom_config then
    print("加载自定义配置文件。")
    dofile( os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privatepath then
        hs.alert("已发现你的私有配置，将优先使用它。")
    end
else
    -- 否则使用默认配置
    if not privatepath then
        privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private')
        -- 如果没有 `~/.hammerspoon/private` 目录，则创建它。
        hs.fs.mkdir(hs.configdir .. '/private')
    end
    privateconf = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privateconf then
        -- 加载自定义配置，如果存在的话
        require('private/config')
    end
end

hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "重新加载配置!", function() hs.reload() end)
    hs.alert.show("配置文件已经重新加载！ ")
end



----------------------------------------------------------------------------------------------------
---------------------------------------- Spoons 加载项 ----------------------------------------------
----------------------------------------------------------------------------------------------------
-- 加载 Spoon
----------------------------------------------------------------------------------------------------
hs.loadSpoon("ModalMgr")

-- 定义默认加载的 Spoons
if not hspoon_list then
    hspoon_list = {
        "KSheet", -- 快捷键
        "WinWin", -- 窗口管理
    }
end

-- 加载 Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end

if spoon.BrightnessControl then
    hsbrightness_keys = hsbrightness_keys or {
        zero = {{"ctrl", "shift"}, "f1"},
        normal = {{"ctrl", "shift"}, "f2"},
    }
    spoon.BrightnessControl:bindHotkeys(hsbrightness_keys)
end

----------------------------------------------------------------------------------------------------
-- 定义各种模式快捷键绑定
----------------------------------------------------------------------------------------------------
-- 定义 windowHints 快捷键
----------------------------------------------------------------------------------------------------
-- hswhints_keys = hswhints_keys or {"alt", "c"}
-- if string.len(hswhints_keys[2]) > 0 then
--     spoon.ModalMgr.supervisor:bind(hswhints_keys[1], hswhints_keys[2], 'WindowHints 快速切换应用', function()
--         spoon.ModalMgr:deactivateAll()
--         if not spoon.WinHints then
--             hs.loadSpoon("WinHints")
--         end
--         spoon.WinHints:show()
--     end)
-- end

--  Alt+tab 应用内窗口切换（快捷键在 private/config.lua 配置）
-- hswindowSwitcher_keys = hswindowSwitcher_keys or {{"alt"}, "tab"}
-- hswindowSwitcher_prev_keys = hswindowSwitcher_prev_keys or {{"alt", "shift"}, "tab"}
-- hscrossAppWindowSwitcher_keys = hscrossAppWindowSwitcher_keys or hsappSwitcher_keys or {{"alt"}, "tab"}
-- hscrossAppWindowSwitcher_prev_keys = hscrossAppWindowSwitcher_prev_keys or hsappSwitcher_prev_keys or {{"alt", "shift"}, "tab"}

-- if not spoon.WinSwitcher then
--     hs.loadSpoon("WinSwitcher")
-- end
-- spoon.WinSwitcher:bindHotkeys({
--     windowNext = hswindowSwitcher_keys,
--     windowPrevious = hswindowSwitcher_prev_keys,
--     -- crossAppNext = hscrossAppWindowSwitcher_keys,
--     -- crossAppPrevious = hscrossAppWindowSwitcher_prev_keys,
-- })


----------------------------------------------------------------------------------------------------
--------------------------------------- appM 快速打开应用 ---------------------------------------------
-- appM 模式 快速打开应用
----------------------------------------------------------------------------------------------------
spoon.ModalMgr:new("appM")
local cmodal = spoon.ModalMgr.modal_list["appM"]
cmodal:bind('', 'escape', 'Quit ', function() spoon.ModalMgr:deactivate({"appM"}) end)
cmodal:bind('', 'Q', 'Quit ', function() spoon.ModalMgr:deactivate({"appM"}) end)
-- cmodal:bind('', 'L', '锁屏 ', function() hs.caffeinate.lockScreen() end)
cmodal:bind('', 'L', 'Launcher ', function()
     hs.spaces.toggleLaunchPad() 
     spoon.ModalMgr:deactivate({"appM"})
    end)
-- cmodal:bind('', 'A', 'Launcher ', function()
--         hs.spaces.toggleLaunchPad() 
--         spoon.ModalMgr:deactivate({"appM"})
--        end)    
cmodal:bind('', 'D', 'Desktop ', function() 
    hs.spaces.toggleShowDesktop() 
    spoon.ModalMgr:deactivate({"appM"})
end)
-- cmodal:bind('', 'E', 'TODO ', function() 
--     hs.execute("open -a /Applications/SimpleMind\\ Pro.app /Users/lilou/w/desktop-media/_TODO.smmx")
--     spoon.ModalMgr:deactivate({"appM"})
-- end)
-- cmodal:bind('', 'C', 'ChatGPT ', function() 
    -- hs.execute("open https://chatgpt.com/")
    -- hs.application.launchOrFocusByBundleID("com.openai.codex")
    -- spoon.ModalMgr:deactivate({"appM"})
-- end)

-- cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
if not hsapp_list then
    hsapp_list = {
        {key = 'f', name = 'Finder'},
        {key = 's', name = 'Safari'},
        {key = 't', name = 'Terminal'},
        {key = 'v', id = 'com.apple.ActivityMonitor'},
        {key = 'y', id = 'com.apple.systempreferences'},
    }
end
for _, v in ipairs(hsapp_list) do
    if v.id then
        local located_name = hs.application.nameForBundleID(v.id)
        if located_name then
            cmodal:bind('', v.key, located_name, function()
                hs.application.launchOrFocusByBundleID(v.id)
                spoon.ModalMgr:deactivate({"appM"})
            end)
        end
    elseif v.name then
        cmodal:bind('', v.key, v.name, function()
            hs.application.launchOrFocus(v.name)
            spoon.ModalMgr:deactivate({"appM"})
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- 通用动作模式
----------------------------------------------------------------------------------------------------
spoon.ModalMgr:new("quickActionM")
local quickActionModal = spoon.ModalMgr.modal_list["quickActionM"]
quickActionModal:bind('', 'escape', '退出', function()
    spoon.ModalMgr:deactivate({"quickActionM"})
end)
quickActionModal:bind('', 'Q', '退出', function()
    spoon.ModalMgr:deactivate({"quickActionM"})
end)

local function runAction(action)
    if action.type == "function" then
        action.action()
    elseif action.type == "text" then
        hs.eventtap.keyStrokes(action.text)
    elseif action.type == "execute" then
        hs.execute(action.command)
    elseif action.type == "url" then
        hs.urlevent.openURL(action.url)
    end
    spoon.ModalMgr:deactivate({"quickActionM"})
end

for _, action in ipairs(hsaction_list or {}) do
    if action.key and action.type then
        quickActionModal:bind('', action.key, action.label or action.type, function()
            runAction(action)
        end)
    end
end

hsquickActionM_keys = hsquickActionM_keys or {"alt", "Q"}
if string.len(hsquickActionM_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(
        hsquickActionM_keys[1],
        hsquickActionM_keys[2],
        "进入通用动作模式",
        function()
            spoon.ModalMgr:deactivateAll()
            spoon.ModalMgr:activate({"quickActionM"}, "#2390FF", true)
        end
    )
end


----------------------------------------------------------------------------------------------------
-- 绑定快捷键
----------------------------------------------------------------------------------------------------
hsappM_keys = hsappM_keys or {"alt", "A"}
if string.len(hsappM_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsappM_keys[1], hsappM_keys[2], " 进入 AppM 模式，快速打开应用", function()
        spoon.ModalMgr:deactivateAll()
        spoon.ModalMgr:activate({"appM"}, "#FFBD2E", true)
    end)
end

----------------------------------------------------------------------------------------------------
-- 在浏览器中打开 Hammerspoon API 手册
----------------------------------------------------------------------------------------------------
hsman_keys = hsman_keys or {"alt", "cmd", "H"}
if string.len(hsman_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsman_keys[1], hsman_keys[2], "查看 Hammerspoon 手册", function()
        hs.doc.hsdocs.forceExternalBrowser(true)
        hs.doc.hsdocs.moduleEntitiesInSidebar(true)
        hs.doc.hsdocs.help()
    end)
end

----------------------------------------------------------------------------------------------------
-- 锁屏
----------------------------------------------------------------------------------------------------
hslock_keys = hslock_keys or {"alt","cmd", "L"}
if string.len(hslock_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hslock_keys[1], hslock_keys[2], "锁屏", function()
        hs.caffeinate.lockScreen()
    end)
end

----------------------------------------------------------------------------------------------------
-- 窗口管理
----------------------------------------------------------------------------------------------------
if spoon.WinWin then
    spoon.ModalMgr:new("resizeM")
    local cmodal = spoon.ModalMgr.modal_list["resizeM"]
    cmodal:bind('', 'escape', '退出 ', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'Q', '退出', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'tab', '键位提示', function() spoon.ModalMgr:toggleCheatsheet() end)

    cmodal:bind('', 'A', '向左移动', function() spoon.WinWin:stepMove("left") end, nil, function() spoon.WinWin:stepMove("left") end)
    cmodal:bind('', 'D', '向右移动', function() spoon.WinWin:stepMove("right") end, nil, function() spoon.WinWin:stepMove("right") end)
    cmodal:bind('', 'W', '向上移动', function() spoon.WinWin:stepMove("up") end, nil, function() spoon.WinWin:stepMove("up") end)
    cmodal:bind('', 'S', '向下移动', function() spoon.WinWin:stepMove("down") end, nil, function() spoon.WinWin:stepMove("down") end)

    cmodal:bind('', 'H', '左半屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfleft") end)
    cmodal:bind('', 'L', '右半屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfright") end)
    cmodal:bind('', 'K', '上半屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfup") end)
    cmodal:bind('', 'J', '下半屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfdown") end)

    cmodal:bind('', 'Y', '屏幕左上角', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNW") end)
    cmodal:bind('', 'O', '屏幕右上角', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNE") end)
    cmodal:bind('', 'U', '屏幕左下角', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSW") end)
    cmodal:bind('', 'I', '屏幕右下角', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSE") end)

    cmodal:bind('', 'F', '全屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen") end)
    cmodal:bind('', 'C', '居中', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center") end)
    cmodal:bind('', 'G', '左三分之二屏居中分屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("centermost") end)
    cmodal:bind('', 'Z', '展示显示', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("show") end)
    cmodal:bind('', 'V', '编辑显示', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("shows") end)

    cmodal:bind('', 'X', '二分之一居中分屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center-2") end)

    cmodal:bind('', '=', '窗口放大', function() spoon.WinWin:moveAndResize("expand") end, nil, function() spoon.WinWin:moveAndResize("expand") end)
    cmodal:bind('', '-', '窗口缩小', function() spoon.WinWin:moveAndResize("shrink") end, nil, function() spoon.WinWin:moveAndResize("shrink") end)

    cmodal:bind('ctrl', 'H', '向左收缩窗口', function() spoon.WinWin:stepResize("left") end, nil, function() spoon.WinWin:stepResize("left") end)
    cmodal:bind('ctrl', 'L', '向右扩展窗口', function() spoon.WinWin:stepResize("right") end, nil, function() spoon.WinWin:stepResize("right") end)
    cmodal:bind('ctrl', 'K', '向上收缩窗口', function() spoon.WinWin:stepResize("up") end, nil, function() spoon.WinWin:stepResize("up") end)
    cmodal:bind('ctrl', 'J', '向下扩镇窗口', function() spoon.WinWin:stepResize("down") end, nil, function() spoon.WinWin:stepResize("down") end)


    cmodal:bind('', 'left', '窗口移至左边屏幕', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("left") end)
    cmodal:bind('', 'right', '窗口移至右边屏幕', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("right") end)
    cmodal:bind('', 'up', '窗口移至上边屏幕', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("up") end)
    cmodal:bind('', 'down', '窗口移动下边屏幕', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("down") end)
    cmodal:bind('', 'space', '窗口移至下一个屏幕', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("next") end)
    cmodal:bind('', 'B', '撤销最后一个窗口操作', function() spoon.WinWin:undo() end)
    cmodal:bind('', 'R', '重做最后一个窗口操作', function() spoon.WinWin:redo() end)

    cmodal:bind('', '[', '左三分之二屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("mostleft") end)
    cmodal:bind('', ']', '右三分之二屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("mostright") end)
    cmodal:bind('', ',', '左三分之一屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("lesshalfleft") end)
    cmodal:bind('', '.', '中分之一屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("onethird") end)
    cmodal:bind('', '/', '右三分之一屏', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("lesshalfright") end)

    cmodal:bind('', 't', '将光标移至所在窗口中心位置', function() spoon.WinWin:centerCursor() end)

    -- 定义窗口管理模式快捷键
    hsresizeM_keys = hsresizeM_keys or {"alt", "R"}
    if string.len(hsresizeM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "进入窗口管理模式", function()
            spoon.ModalMgr:deactivateAll()
            -- 显示状态指示器，方便查看所处模式
            spoon.ModalMgr:activate({"resizeM"}, "#B22222")
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- 绑定 KSheet 面板 快捷键
----------------------------------------------------------------------------------------------------
if spoon.KSheet then
    spoon.ModalMgr:new("cheatsheetM")
    local cmodal = spoon.ModalMgr.modal_list["cheatsheetM"]
    cmodal:bind('', 'escape', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)

    -- 定义快捷键
    hscheats_keys = hscheats_keys or {"alt", "S"}
    if string.len(hscheats_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hscheats_keys[1], hscheats_keys[2], "显示应用快捷键", function()
            spoon.KSheet:show()
            spoon.ModalMgr:deactivateAll()
            spoon.ModalMgr:activate({"cheatsheetM"})
        end)
    end
end

-- 粘贴浏览器最前置的标题和地址
----------------------------------------------------------------------------------------------------
hstype_keys = hstype_keys or {"alt", "V"}
if string.len(hstype_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hstype_keys[1], hstype_keys[2], "粘贴浏览器最前置页面标题和地址", function()
        local safari_running = hs.application.applicationsForBundleID("com.apple.Safari")
        local chrome_running = hs.application.applicationsForBundleID("com.google.Chrome")
        if #safari_running > 0 then
            local stat, data = hs.applescript('tell application "Safari" to get {URL, name} of current tab of window 1')
            if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
        elseif #chrome_running > 0 then
            local stat, data = hs.applescript('tell application "Google Chrome" to get {URL, title} of active tab of window 1')
            if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
        end
    end)
end



----------------------------------------------------------------------------------------------------
-- 快捷显示 Hammerspoon 控制台
----------------------------------------------------------------------------------------------------
hsconsole_keys = hsconsole_keys or {"alt", "Z"}
if string.len(hsconsole_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsconsole_keys[1], hsconsole_keys[2], "打开 Hammerspoon 控制台", function() hs.toggleConsole() end)
end

----------------------------------------------------------------------------------------------------
-- 方向控制 
----------------------------------------------------------------------------------------------------
-- https://stackoverflow.com/questions/40986242/key-repeats-are-delayed-in-my-hammerspoon-script

local fastKeyStroke = function(modifiers, character)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, string.lower(character), true):post()
  event.newKeyEvent(modifiers, string.lower(character), false):post()
end

local altHyper = {"alt"}
hs.fnutils.each({
  -- Movement
  { key='h', mod={}, direction='left'},
  { key=',', mod={}, direction='down'},
  { key='i', mod={}, direction='up'},
  { key='l', mod={}, direction='right'},
  { key='0', mod={'cmd'}, direction='left'},  -- beginning of line
  { key='4', mod={'cmd'}, direction='right'}, -- end of line
  { key='b', mod={'alt'}, direction='left'},  -- back word
  { key='f', mod={'alt'}, direction='right'}, -- forward word
  { key='u', mod={}, direction='pageup'},
  { key='e', mod={}, direction='pageup'},
  { key='d', mod={}, direction='pagedown'},
}, function(hotkey)
  hs.hotkey.bind(altHyper, hotkey.key, 
      function() fastKeyStroke(hotkey.mod, hotkey.direction) end,
      nil,
      function() fastKeyStroke(hotkey.mod, hotkey.direction) end
    )
  end
)

local altShiftHyper = {"alt","shift"}
hs.fnutils.each({
  -- Movement
  { key='h', mod={"shift"}, direction='left'},
  { key=',', mod={"shift"}, direction='down'},
  { key='i', mod={"shift"}, direction='up'},
  { key='l', mod={"shift"}, direction='right'},
  { key='0', mod={"shift","cmd"}, direction='left'},  -- beginning of line
  { key='4', mod={"shift","cmd"}, direction='right'}, -- end of line
  { key='b', mod={"shift","alt"}, direction='left'},  -- back word
  { key='f', mod={"shift","alt"}, direction='right'}, -- forward word
}, function(hotkey)
  hs.hotkey.bind(altShiftHyper, hotkey.key, 
      function() fastKeyStroke(hotkey.mod, hotkey.direction) end,
      nil,
      function() fastKeyStroke(hotkey.mod, hotkey.direction) end
    )
  end
)

-- shift-alt-left
hs.hotkey.bind({"shift", "alt", "ctrl"}, "h", 
    function() fastKeyStroke({"shift", "alt"}, "left")end,
    nil,
    function() fastKeyStroke({"shift", "alt"}, "left")end
)
-- shift-alt-right
hs.hotkey.bind({"shift", "alt", "ctrl"}, "l", 
    function() fastKeyStroke({"shift", "alt"}, "right")end,
    nil,
    function() fastKeyStroke({"shift", "alt"}, "right")end
)
-- del
hs.hotkey.bind({"alt"}, "'", 
      function() fastKeyStroke({}, "forwarddelete") end,
      nil,
      function() fastKeyStroke({}, "forwarddelete") end
)
----------------------------------------------------------------------------------------------------
-- 初始化 modalMgr
----------------------------------------------------------------------------------------------------

spoon.ModalMgr.supervisor:enter()



----------------------------------------------------------------------------------------------------
-------------------------------------------- End ---------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 将 shift+option+z 绑定到插入当前时间的函数
-- 获取当前时间并将其插入到当前应用程序的光标位置
hs.hotkey.bind({"shift", "option"}, "z", function() hs.eventtap.keyStrokes(os.date("%Y-%m-%d %H:%M:%S")) end)
hs.hotkey.bind({"shift", "option"}, "x", function() hs.eventtap.keyStrokes("执行计划和我确认") end)
hs.hotkey.bind({"shift", "option"}, "c", function() hs.eventtap.keyStrokes("执行") end)
