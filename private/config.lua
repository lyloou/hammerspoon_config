----------------------------------------------------------------------------------------------------

-- author: zuorn
-- mail: zuorn@qq.com
-- github: https://github.com/zuorn/hammerspoon_config

----------------------------------------------------------------------------------------------------

----------------------------------------- 配 置 文 件 -----------------------------------------------

----------------------------------------------------------------------------------------------------

--指定要启用的模块
hspoon_list = {
    -- "BingDaily",
    "KSheet",
    "WinWin",
    "BrightnessControl",
}

----------------------------------------------------------------------------------------------------
----------------------------------------- 快速启动配置  ----------------------------------------------

-- 绑定 启动 app 快捷键

hsapp_list = {
    {key = '1', name = 'Cursor'},
    {key = '2', id = 'com.google.Chrome'},
    {key = '3', name = 'IntelliJ IDEA'},
    {key = '4', id = 'com.kingsoft.wpsoffice.mac'},
    {key = '5', name = 'WindTerm'},

    {key = 'a', name = 'Notes'},
    {key = 'b', name = 'Typora'},
    {key = 'c', id = 'com.openai.codex'},
    -- {key = 'c', id = 'com.anthropic.claudefordesktop'},
    -- {key = 'c', id = 'com.openai.atlas'},
    -- {key = 'c', id = 'com.google.Chrome'},
    {key = 'e', id = 'md.obsidian'},
    {key = 'r', id = 'com.apple.reminders'},
    {key = 's', id = 'com.modelmakertools.simplemindmacpro'},
    {key = 't', id = 'com.lyloou.texttool'},
    -- {key = 'f', id = 'com.jinghaoshe.qspace.pro'},
    {key = 'f', name = 'Finder'},
    {key = 'g', name = 'IntelliJ IDEA'},
    {key = 'k', name = 'Keynote'},
    -- {key = 'o', name = 'Apifox'},
    {key = 'o', id = 'com.usebruno.app'},
    -- {key = 'p', id = 'com.jetbrains.pycharm'},
    {key = 'v', id = 'com.apple.ActivityMonitor'},
    {key = 'w', id = 'net.cozic.joplin-desktop'},
    -- {key = 'm', id = 'com.netease.163music'},
    -- {key = 'n', id = 'com.navicat.NavicatPremium'},
    -- {key = 'n', id = 'com.dameng.sxypt'},
    {key = 'n', id = 'com.dbx.app'},
    -- {key = 'x', id = 'com.anthropic.claudefordesktop'},
    {key = 'x', id = 'dev.warp.Warp-Stable'},
    {key = 'y', id = 'com.apple.systempreferences'},
    -- {key = 'z', id = 'com.github.wez.wezterm'}
    {key = 'z', id = 'com.mitchellh.ghostty'}
}

-- 通用动作配置：由 Alt+Q 进入动作模式后按对应字母触发
hsaction_list = {
    {key = "z", label = "打开 Hammerspoon 控制台", type = "function", action = function()
        hs.toggleConsole()
    end},
    {key = "l", label = "锁定屏幕", type = "function", action = function()
        hs.caffeinate.lockScreen()
    end},
    {key = "t", label = "插入当前时间", type = "function", action = function()
        hs.eventtap.keyStrokes(os.date("%Y-%m-%d %H:%M:%S"))
    end},
    {key = "x", label = "执行计划和我确认", type = "text", text = "执行计划和我确认"},
    {key = "c", label = "执行", type = "text", text = "执行"},
    {
        key = "v",
        label = "粘贴浏览器 Markdown 链接",
        type = "function",
        action = function()
            local app = hs.application.frontmostApplication()
            local bundleID = app and app:bundleID()
            local script
            if bundleID == "com.google.Chrome" then
                script = 'tell application "Google Chrome" to get {URL, title} of active tab of window 1'
            end
            if script then
                local stat, data = hs.applescript(script)
                if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
            end
        end,
    },
    {
        key = "m",
        label = "打开工具箱",
        type = "execute",
        command = "open -a /Applications/SimpleMind\\ Pro.app ~/w/coocaa/coocaa-project/A-工具箱/A-工具箱.smmx",
    },
    {
        key = "o",
        label = "打开 DevOps",
        type = "url",
        url = "http://cloud.coocaa.io/deploy/user/svc/deploy",
    },
}

----------------------------------------------------------------------------------------------------
---------------------------------------- 模式快捷键绑定  ----------------------------------------------

-- 快速启动面板快捷键绑定
hsappM_keys = {"alt", "A"}

-- 在默认浏览器中打开 Hammerspoon 和 Spoons API 手册
--hsman_keys = {"alt", "H"}

-- 锁定电脑快捷键绑定
--hslock_keys = {"alt", "L"}

-- 窗口自定义大小及位置快捷键绑定
hsresizeM_keys = {"alt", "R"}

-- 定义应用程序快捷键面板快捷键
hscheats_keys = {"alt", "S"}

-- 粘贴 chrome 或 safari 打开最前置的网址
-- hstype_keys = {"alt", "V"}

-- 显示 Hammerspoon 控制台
-- hsconsole_keys = {"alt", "Z"}


----------------------------------------------------------------------------------------------------
--------------------------------- hammerspoon 快捷键绑定配置  -----------------------------------------

-- 临时禁用所有快捷键(注意：只能手动接禁。)
hsupervisor_keys = {{"cmd", "shift", "ctrl"}, "Q"}

-- 重新加载配置文件
hsreload_keys = {{"cmd", "shift", "ctrl"}, "R"}

-- 显示各种模式绑定快捷键
hshelp_keys = {{"alt", "shift"}, "/"}


hsbrightness_keys = {
    zero = {{"ctrl", "shift"}, "f1"},
    normal = {{"ctrl", "shift"}, "f2"},
}

----------------------------------------------------------------------------------------------------
----------------------------------------- 屏幕焦点切换 -----------------------------------------------
-- Option + Ctrl + Shift + [: 上一个屏幕  ]: 下一个屏幕 (鼠标移至屏幕中心)
----------------------------------------------------------------------------------------------------
local function focusScreen(dir)
    local screens = hs.screen.allScreens()
    local current = hs.mouse.getCurrentScreen()
    local idx = 1
    for i, s in ipairs(screens) do
        if s:id() == current:id() then idx = i; break end
    end
    local target = screens[(idx - 1 + dir + #screens) % #screens + 1]
    local f = target:frame()
    hs.mouse.setAbsolutePosition({x = f.x + f.w / 2, y = f.y + f.h / 2})
    for _, w in ipairs(hs.window.orderedWindows()) do
        if w:screen():id() == target:id() and w:isStandard() then
            w:focus()
            break
        end
    end
end

-- hs.hotkey.bind({"alt","ctrl","shift"}, "[", function() focusScreen(-1) end)
-- hs.hotkey.bind({"alt","ctrl","shift"}, "]", function() focusScreen(1) end)

----------------------------------------------------------------------------------------------------
---------------------------------------------- end  ------------------------------------------------
----------------------------------------------------------------------------------------------------
