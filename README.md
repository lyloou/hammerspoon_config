# Hammerspoon 自动化配置

这是一个面向 macOS 的 Hammerspoon 配置，提供模态快捷键、应用启动、窗口管理、应用快捷键查看和常用文本/命令动作。

## 安装

安装 Hammerspoon：

```sh
brew install --cask hammerspoon
```

将仓库放到 Hammerspoon 配置目录：

```sh
git clone https://github.com/lyloou/hammerspoon_config ~/.hammerspoon
```

打开 Hammerspoon 后，使用 `Cmd+Shift+Ctrl+R` 重载配置。

## 快捷键

### 通用约定

模态使用“前缀键 + 模态内按键”的两级结构。模态均可用 `Esc` 或 `Q` 退出。

`Cmd+Shift+Ctrl+P` 切换 supervisor 中的全部快捷键；`Cmd+Shift+Ctrl+R` 重载配置。

界面主题、透明度和字体主色在 `private/config.lua` 中配置：`theme` 支持 `"dark"` 和 `"light"`，默认是 `"dark"`；`opacity` 范围为 `0` 到 `1`，默认是 `0.75`；`fontColor` 使用 `#RRGGBB` 格式，默认青色 `"#67D8D1"`，例如粉色 `"#FF79C6"` 或蓝色 `"#5AA9FF"`。

模态快捷键面板默认使用 `images/modal-background.png` 作为背景。通过 `backgroundImage` 可指定相对于 Hammerspoon 配置目录的图片或绝对路径；设为 `false` 可关闭背景图。

### 应用启动

`Option+A` 进入应用启动模式。应用字母和对应程序在 `private/config.lua` 的 `apps` 中配置；`L` 打开 Launchpad，`D` 显示桌面。

### 通用动作

`Option+Q` 进入通用动作模式：

| 按键 | 动作 |
|---|---|
| `P` | 切换全部快捷键 |
| `Z` | 打开 Hammerspoon Console |
| `L` | 锁定屏幕 |
| `T` | 插入当前时间 |
| `X` | 插入“执行计划和我确认” |
| `C` | 插入“执行” |
| `V` | 从前台 Chrome 插入当前页面的 Markdown 链接 |
| `M` | 打开 SimpleMind 工具箱 |
| `O` | 打开 DevOps |

另外保留三个直接动作别名：

- `Shift+Option+Z`：插入当前时间
- `Shift+Option+X`：插入“执行计划和我确认”
- `Shift+Option+C`：插入“执行”

### 窗口管理

`Option+R` 进入 `WinWin` 窗口管理模式：

- `W/A/S/D`：按步移动窗口
- `H/J/K/L`：左、下、上、右半屏
- `Y/O/U/I`：左上、右上、左下、右下四分之一屏
- `F`：全屏；`C`：居中；`G`：左三分之二屏；`X`：居中二分之一屏
- `Z/V`：预设展示布局
- `=` / `-`：放大 / 缩小
- `Ctrl+H/J/K/L`：按步调整窗口尺寸
- 方向键：移动到对应方向的屏幕；`Space`：移动到下一块屏幕
- `B/R`：撤销 / 重做窗口操作；`T`：将鼠标移到窗口中心
- `Tab`：显示当前模态的键位提示

### 其他

- `Option+Q` 后按 `S`：显示当前应用的菜单快捷键（KSheet）
- `Ctrl+Shift+F1/F2`：亮度归零 / 恢复普通亮度
- `Alt+Cmd+H`：打开 Hammerspoon API 手册

## 光标移动（重点）

这组快捷键是本配置中最常用的效率功能之一：使用 `Option` 加方向键映射，在不离开主键区的情况下移动光标。

### 基本移动

| 快捷键 | 作用 |
|---|---|
| `Option+H` | 向左移动一个字符 |
| `Option+L` | 向右移动一个字符 |
| `Option+I` | 向上移动一行 |
| `Option+,` | 向下移动一行 |
| `Option+B` | 向左移动一个单词 |
| `Option+F` | 向右移动一个单词 |
| `Option+Cmd+0` | 移到行首 |
| `Option+Cmd+4` | 移到行尾 |
| `Option+U` | 向上翻页 |
| `Option+E` | 向上翻页 |
| `Option+D` | 向下翻页 |

### 选区扩展

按住 `Shift`，即可将对应移动改为选中：

- `Option+Shift+H/L`：向左 / 向右选择字符
- `Option+Shift+I/,`：向上 / 向下选择
- `Option+Shift+B/F`：按单词选择
- `Option+Shift+Cmd+0/4`：选择到行首 / 行尾
- `Ctrl+Option+Shift+H/L`：按单词向左 / 向右选择

`Option+'`：前向删除。

## 配置

所有个人化配置位于 `private/config.lua`，文件返回一个 Lua 表：

```lua
return {
    fontColor = "#FF79C6",
    backgroundImage = "images/modal-background.png",
    spoons = {"KSheet", "WinWin", "BrightnessControl"},
    apps = {
        {key = "c", id = "com.openai.codex"},
    },
    actions = {
        {id = "openDevOps", key = "o", label = "打开 DevOps", type = "url", url = "https://example.com"},
    },
}
```

配置文件只保存数据，不调用 Hammerspoon API。`function` 动作通过 `name` 引用 `init.lua` 中已有的动作处理器；新增通用行为时，应先在 `init.lua` 增加处理器，再在配置中声明动作。

支持外部私有配置路径 `~/.config/hammerspoon/private/config.lua`；该文件存在时优先于 `~/.hammerspoon/private/config.lua`。

## 目录结构

```text
init.lua                  运行时入口和行为实现
private/config.lua        个人化声明式配置
Spoons/ModalMgr.spoon     模态基础设施
Spoons/WinWin.spoon       窗口管理
Spoons/KSheet.spoon       应用快捷键面板
Spoons/BrightnessControl.spoon 亮度控制
```
