----------------------------------------------------------------------------------------------------

-- author: zuorn
-- mail: zuorn@qq.com
-- github: https://github.com/zuorn/hammerspoon_config

----------------------------------------------------------------------------------------------------

----------------------------------------- 配 置 文 件 -----------------------------------------------

----------------------------------------------------------------------------------------------------

--指定要启用的模块
hspoon_list = {
    -- "AClock",
    -- "ClipShow",
    -- "CountDown",
    "KSheet",
    "WinWin",
    "VolumeScroll",
    "QuickText",
    "PopupTranslateSelection",
    -- "DeepLTranslate",
    -- "HSaria2",
    -- "HSearch",
    -- "SpeedMenu",
    -- "MountedVolumes",
    -- "HeadphoneAutoPause",
}

----------------------------------------------------------------------------------------------------
----------------------------------------- 快速启动配置  ----------------------------------------------

-- 绑定 启动 app 快捷键

hsapp_list = {
    {key = '1', name = 'Cursor'},
    {key = '2', id = 'com.google.Chrome'},
    -- {key = '2', id = 'com.openai.atlas'},
    {key = '3', name = 'IntelliJ IDEA'},
    {key = '4', id = 'com.kingsoft.wpsoffice.mac'},
    {key = '5', name = 'WindTerm'},

    {key = 'a', name = 'Notes'},
    {key = 't', id = 'com.apple.reminders'},
    {key = 'b', name = 'Typora'},
    -- {key = 'c', id = 'com.openai.chat'},
    -- {key = 'c', id = 'com.openai.atlas'},
    -- {key = 'c', id = 'com.google.Chrome'},
    {key = 'e', id = 'md.obsidian'},
    {key = 's', id = 'com.modelmakertools.simplemindmacpro'},
    -- {key = 'f', id = 'com.jinghaoshe.qspace.pro'},
    {key = 'f', name = 'Finder'},
    {key = 'g', name = 'IntelliJ IDEA'},
    {key = 'k', name = 'Keynote'},
    {key = 'o', name = 'Apifox'},
    -- {key = 'p', id = 'com.jetbrains.pycharm'},
    {key = 'v', id = 'com.apple.ActivityMonitor'},
    {key = 'w', id = 'net.cozic.joplin-desktop'},
    -- {key = 'm', id = 'com.netease.163music'},
    {key = 'n', id = 'com.navicat.NavicatPremium'},
    {key = 'x', id = 'com.anthropic.claudefordesktop'},
    {key = 'y', id = 'com.apple.systempreferences'},
    -- {key = 'z', id = 'com.github.wez.wezterm'}
    {key = 'z', id = 'com.mitchellh.ghostty'}
}

-- 快捷文字配置脚本
QuickText_list = {
    -- open url
    ["oo1"] =
    {
        ["type"] = "url",
        ["url"] = "https://www.hammerspoon.org/",
    },
    ["oo2"] =
    {
        ["type"] = "url",
        ["url"] = "https://www.v2ex.com/",
    },
    ["oo3"] =
    {
        ["type"] = "url",
        ["url"] = "https://github.com/",
    },
    -- search text
    ["gg"] =
    {
        ["type"] = "search",
        ["text"] = "https://www.google.com/search?q=",
    },

    --  expand text
    ["t1"] =
    {
        ["type"] = "text",
        ["text"] = "15057466****",
    },
    -- todo
    ["todo"] =
    {
        ["type"] = "text",
        ["text"] = "//TODO:",
    },
}

----------------------------------------------------------------------------------------------------
---------------------------------------- 模式快捷键绑定  ----------------------------------------------

-- 窗口提示键绑定，快速切换到你想要的窗口上
hswhints_keys = {"alt", "tab"}

-- 快速启动面板快捷键绑定
hsappM_keys = {"alt", "A"}

-- 系统剪切板快捷键绑定
-- hsclipsM_keys = {"alt", "C"}


-- 在默认浏览器中打开 Hammerspoon 和 Spoons API 手册
--hsman_keys = {"alt", "H"}

-- 倒计时快捷键绑定
-- hscountdM_keys = {"alt", "I"}

-- 锁定电脑快捷键绑定
--hslock_keys = {"alt", "L"}

-- 窗口自定义大小及位置快捷键绑定
hsresizeM_keys = {"alt", "R"}

-- 定义应用程序快捷键面板快捷键
hscheats_keys = {"alt", "S"}

-- 显示时钟快捷键绑定
-- hsaclock_keys = {"alt", "w"}

-- 粘贴 chrome 或 safari 打开最前置的网址
-- hstype_keys = {"alt", "V"}

-- 显示 Hammerspoon 控制台
-- hsconsole_keys = {"alt", "Z"}

-- 显示 MountedVolumes
-- hstype_keys = {"alt", "M"}

-- 显示搜索
-- hsearch_keys = {"alt", "Gq"}

----------------------------------------------------------------------------------------------------
--------------------------------- hammerspoon 快捷键绑定配置  -----------------------------------------

-- 临时禁用所有快捷键(注意：只能手动接禁。)
hsupervisor_keys = {{"cmd", "shift", "ctrl"}, "Q"}

-- 重新加载配置文件
hsreload_keys = {{"cmd", "shift", "ctrl"}, "R"}

-- 显示各种模式绑定快捷键
hshelp_keys = {{"alt", "shift"}, "/"}


----------------------------------------------------------------------------------------------------
----------------------------------------- 屏幕亮度控制 -----------------------------------------------
-- Option + Ctrl + Shift + 0: 0%  9: 100%  -: -10  =: +10（所有活动显示器同步，见 plugins/set_brightness）
----------------------------------------------------------------------------------------------------
local _brightnessBin = hs.configdir .. "/plugins/set_brightness"
local _brightnessStep = 10
--- 当前亮度百分比（0～100），用于增减步进；可能与外接屏实际值略不同步。
local _brightnessLevel = math.floor(hs.brightness.get())

--- 将亮度设为 0～100，优先调用 plugins/set_brightness（0～1 浮点）同步各屏；无二进制时回退 hs.brightness。
---@param level number 目标亮度（百分比）
local function setBrightness(level)
    level = math.max(0, math.min(100, math.floor(level + 0.5)))
    _brightnessLevel = level
    local frac = string.format("%.4f", level / 100)
    if hs.fs.attributes(_brightnessBin, "mode") then
        hs.task.new(_brightnessBin, function(exitCode, _, stdErr)
            if exitCode ~= 0 then
                hs.alert.show("set_brightness 失败: " .. (stdErr or ("exit " .. tostring(exitCode))), 1.5)
            end
        end, { frac }):start()
    else
        hs.brightness.set(level)
    end
    hs.alert.show("亮度 " .. level .. "%")
end

hs.hotkey.bind({"ctrl", "shift"}, "f1", function() setBrightness(0) end)
hs.hotkey.bind({"ctrl", "shift"}, "f2", function() setBrightness(90) end)
-- hs.hotkey.bind({"alt", "ctrl", "shift"}, "-", function() setBrightness(_brightnessLevel - _brightnessStep) end)
-- hs.hotkey.bind({"alt", "ctrl", "shift"}, "=", function() setBrightness(_brightnessLevel + _brightnessStep) end)

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
