--- === KSheet ===
---
--- Keybindings cheatsheet for current application
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/KSheet.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/KSheet.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "KSheet"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Workaround for "Dictation" menuitem
hs.application.menuGlyphs[148]="fn fn"

obj.commandEnum = {
    cmd = '⌘',
    shift = '⇧',
    alt = '⌥',
    ctrl = '⌃',
}

function obj:init()
    self.sheetView = hs.webview.new({x=0, y=0, w=0, h=0})
    self.renderToken = 0
    self.htmlCache = {}
    self.sheetView:windowTitle("CheatSheets")
    self.sheetView:windowStyle("utility")
    self.sheetView:transparent(true)
    self.sheetView:alpha(hammerspoon_opacity or 0.75)
    self.sheetView:allowGestures(true)
    self.sheetView:allowNewWindows(false)
    self.sheetView:level(hs.drawing.windowLevels.modalPanel)
end

local function processMenuItems(menustru)
    local menu = ""
        for pos,val in pairs(menustru) do
            if type(val) == "table" then
                -- TODO: Remove menubar items with no shortcuts in them
                if val.AXRole == "AXMenuBarItem" and type(val.AXChildren) == "table" then
                    menu = menu .. "<ul class='col col" .. pos .. "'>"
                    menu = menu .. "<li class='title'><strong>" .. val.AXTitle .. "</strong></li>"
                    menu = menu .. processMenuItems(val.AXChildren[1])
                    menu = menu .. "</ul>"
                elseif val.AXRole == "AXMenuItem" and not val.AXChildren then
                    if not (val.AXMenuItemCmdChar == '' and val.AXMenuItemCmdGlyph == '') then
                        local CmdModifiers = ''
                        for key, value in pairs(val.AXMenuItemCmdModifiers) do
                            CmdModifiers = CmdModifiers .. obj.commandEnum[value]
                        end
                        local CmdChar = val.AXMenuItemCmdChar
                        local CmdGlyph = hs.application.menuGlyphs[val.AXMenuItemCmdGlyph] or ''
                        local CmdKeys = CmdChar .. CmdGlyph
                        menu = menu .. "<li><div class='cmdModwifiers'>" .. CmdModifiers .. " " .. CmdKeys .. "</div><div class='cmdtext'>" .. " " .. val.AXTitle .. "</div></li>"
                    end
                elseif val.AXRole == "AXMenuItem" and type(val.AXChildren) == "table" then
                    menu = menu .. processMenuItems(val.AXChildren[1])
                end
            end
        end
    return menu
end

local function generateHtml(application)
    local menuitems_tree = application:getMenuItems()
    local allmenuitems = processMenuItems(menuitems_tree)

    local theme = hammerspoon_theme == "light" and "light" or "dark"
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
        <style type="text/css">
            *{margin:0; padding:0;}
            :root{
              color-scheme: dark;
              --bg:#121820;
              --surface:#121820;
              --line:#33414f;
              --text:#e8eef2;
              --muted:#8d9ba6;
              --accent:#67d8d1;
            }
            body.light{
              color-scheme: light;
              --bg:#f4f6f8;
              --surface:#f4f6f8;
              --line:#cdd5dc;
              --text:#17212b;
              --muted:#5d6b76;
              --accent:#147a78;
            }
            html, body{
              background-color:var(--bg);
              color:var(--text);
              font-family:-apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
              font-size: 13px;
            }
            body{
              border:1px solid var(--line);
              border-radius:12px;
              box-sizing:border-box;
              overflow:hidden;
              scrollbar-color:var(--line) var(--bg);
            }
            a{
              text-decoration:none;
              color:var(--muted);
              font-size:12px;
            }
            li.title{
              text-align:center;
              color:var(--accent);
              font-family:"Courier-Bold", monospace;
              letter-spacing:0.04em;
            }
            ul, li{list-style: inside none; padding: 0 0 5px;}
            li.title{padding: 0 10px 15px}
            .content{
              padding: 0;
              font-size:12px;
              overflow:hidden;
            }
            .content.maincontent{
              position: relative;
              margin-top: 0;
              display:grid;
              grid-template-columns:repeat(auto-fit, minmax(240px, 1fr));
              gap:16px;
              max-height:100vh;
              overflow:auto;
            }
            .content > .col{
              width:auto;
              min-width:0;
              padding:20px 16px;
              border-left:1px solid var(--line);
            }

            li:after{
              visibility: hidden;
              display: block;
              font-size: 0;
              content: " ";
              clear: both;
              height: 0;
            }
            .cmdModifiers{
              width: 60px;
              padding-right: 15px;
              text-align: right;
              float: left;
              font-family:"Courier-Bold", monospace;
              font-weight: bold;
              color:var(--accent);
            }
            .cmdtext{
              float: left;
              overflow: hidden;
              width: calc(100% - 75px);
              color:var(--text);
            }
        </style>
        </head>
          <body class="]] .. theme .. [[">
            <div class="content maincontent">]] .. allmenuitems .. [[</div>

          </body>
        </html>
        ]]

    return html
end

local function loadingHtml(application)
    local theme = hammerspoon_theme == "light" and "light" or "dark"
    local background = theme == "light" and "#F4F6F8" or "#121820"
    local text = theme == "light" and "#147A78" or "#67D8D1"
    return string.format([[<html><body class="%s" style="background:%s;color:%s;font-family:-apple-system,sans-serif;padding:32px">读取 %s 菜单...</body></html>]], theme, background, text, application:title())
end

--- KSheet:show()
--- Method
--- Show current application's keybindings in a webview
---

function obj:show()
    local capp = hs.application.frontmostApplication()
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    self.sheetView:frame({
        x = cres.x + cres.w / 5,
        y = cres.y + cres.h / 5,
        w = cres.w / 5 * 3,
        h = cres.h / 5 * 3
    })
    self.renderToken = self.renderToken + 1
    local token = self.renderToken
    local cacheKey = capp:bundleID() or capp:title()
    self.sheetView:html(self.htmlCache[cacheKey] or loadingHtml(capp))
    self.sheetView:show()
    hs.timer.doAfter(0, function()
        if token == self.renderToken then
            local webcontent = self.htmlCache[cacheKey] or generateHtml(capp)
            self.htmlCache[cacheKey] = webcontent
            self.sheetView:html(webcontent)
            hs.timer.doAfter(0.05, function()
                if token ~= self.renderToken then
                    return
                end
                self.sheetView:evaluateJavaScript("document.body.scrollHeight", function(height)
                    local contentHeight = tonumber(height)
                    if not contentHeight then
                        return
                    end
                    local frame = self.sheetView:frame()
                    local screenHeight = hs.screen.mainScreen():fullFrame().h
                    frame.h = math.min(math.max(contentHeight + 16, 180), screenHeight * 0.75)
                    self.sheetView:frame(frame)
                end)
            end)
        end
    end)
end

--- KSheet:hide()
--- Method
--- Hide the cheatsheet webview
---

function obj:hide()
    self.sheetView:hide()
end

return obj
