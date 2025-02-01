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
    {key = '3', name = 'IntelliJ IDEA'},
    {key = '4', id = 'com.kingsoft.wpsoffice.mac'},

    {key = 'a', name = 'Notes'},
    {key = 'b', name = 'Typora'},
    {key = 'c', id = 'com.modelmakertools.simplemindmacpro'},
    {key = 'f', name = 'Finder'},
    {key = 'g', name = 'DataGrip'},
    {key = 'i', name = 'IntelliJ IDEA'},
    {key = 'j', name = 'Typora'},
    {key = 'k', name = 'Keynote'},
    {key = 'o', name = 'Apifox'},
    {key = 'p', name = 'Podcasts'},
    {key = 't', name = 'WindTerm'},
    {key = 'v', id = 'com.apple.ActivityMonitor'},
    {key = 'm', id = 'com.netease.163music'},
    {key = 'n', id = 'com.navicat.NavicatForMySQL'},
    {key = 'w', name = 'Typora'},
    {key = 'y', id = 'com.apple.systempreferences'},
    {key = 'z', name = 'Alacritty'}
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
---------------------------------------------- end  ------------------------------------------------
----------------------------------------------------------------------------------------------------
