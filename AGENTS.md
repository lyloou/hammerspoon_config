# AGENTS.md

## 项目概览

这是一个运行在 macOS Hammerspoon 上的 Lua 自动化配置，入口是 `init.lua`，配置目录是 `~/.hammerspoon`。

## 重载与验证

编辑任意 Lua 文件后，用 `Cmd+Shift+Ctrl+R` 重载配置，或从 Hammerspoon 菜单栏选择 Reload Config。运行时错误会出现在 Hammerspoon Console；当前可通过 `Option+Q` 后按 `Z` 打开控制台。

修改前优先使用 LuaJIT 语法检查和 `git diff --check`。除非任务明确要求，不使用浏览器截图、浏览器交互或 Computer Use 作为验证手段。

## 代码职责

`init.lua` 只负责运行时行为：

- 加载本地或外部私有配置，外部配置优先
- 初始化 `ModalMgr` 和配置中启用的 Spoons
- 实现命名动作处理器和通用动作分发
- 创建模态、注册 Hammerspoon API 调用和快捷键

`private/config.lua` 只返回声明式配置表，不调用 `hs.*` API、不注册快捷键、不定义运行时函数。配置表包括：

- `theme`：界面主题，支持 `dark` 和 `light`，默认 `dark`
- `opacity`：界面透明度，范围 `0` 到 `1`，默认 `0.75`
- `backgroundImage`：模态快捷键面板背景图路径，默认启用 `images/modal-background.png`，使用 `false` 禁用
- `spoons`：要加载的 Spoon 名称
- `apps`：`appM` 中的应用启动项，格式为 `{key, name}` 或 `{key, id}`
- `actions`：`quickActionM` 动作。支持 `text`、`execute`、`url`、`function`；`function` 通过 `name` 引用 `init.lua` 中的动作处理器
- `hotkeys`：模态前缀和全局快捷键；可选绑定使用 `false` 禁用
- `brightness`：`BrightnessControl` 的热键映射
- `globalAliases`：直接触发已配置动作的全局快捷键别名

## 模态约定

模态采用两级按键结构：前缀键进入模态，模态内的字母执行操作。所有当前模态都使用 `Esc` 或 `Q` 退出。`Cmd+Shift+Ctrl+P` 切换 supervisor 中的全部快捷键。

当前模态：

- `Option+A`：应用启动模式 `appM`
- `Option+Q`：通用动作模式 `quickActionM`
- `Option+R`：窗口管理模式 `resizeM`
- `Option+Q` 后按 `S`：当前应用快捷键面板 `cheatsheetM`

## 当前启用的 Spoons

- `ModalMgr`：模态基础设施，始终由入口加载
- `KSheet`：读取当前应用菜单快捷键并显示面板
- `WinWin`：窗口移动、调整大小、跨屏幕、撤销和重做
- `BrightnessControl`：显示器亮度快捷控制

`WinHints` 和 `WinSwitcher` 已移除，不应重新加入配置或文档引用。

## 光标移动快捷键

光标导航是当前配置的核心效率功能，定义在 `init.lua` 的 `fastKeyStroke` 映射中：

- `Option+H/L`：左右移动字符；`Option+I/,`：上下移动
- `Option+B/F`：按单词左右移动
- `Option+Cmd+0/4`：移动到行首或行尾
- `Option+U/E/D`：翻页
- 对应组合加 `Shift`：扩展选区
- `Ctrl+Option+Shift+H/L`：按单词扩展选区
- `Option+'`：前向删除

修改这组快捷键时，应同时更新 README 的“光标移动（重点）”章节，并用长按测试确认按键重复行为正常。

## 编辑原则

- 新增个人行为时优先修改 `private/config.lua` 的数据项
- 新增通用 Hammerspoon 行为时，在 `init.lua` 增加命名处理器，再由配置通过名称引用
- 不在配置文件中复制快捷键注册逻辑
- 保持现有快捷键兼容；删除或迁移快捷键时同步更新 README 和本文件
