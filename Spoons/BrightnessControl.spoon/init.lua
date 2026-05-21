--- === BrightnessControl ===
---
--- Control display brightness across active displays.

local obj = {}
obj.__index = obj

obj.name = "BrightnessControl"
obj.version = "1.0"
obj.author = "lilou"
obj.license = "MIT"

obj.step = 10
obj.defaultLevels = {
    zero = 0,
    normal = 85,
}

local function scriptPath()
    local source = debug.getinfo(2, "S").source:sub(2)
    return source:match("(.*/)")
end

obj.spoonPath = scriptPath()

function obj:init()
    self.binaryPath = self.spoonPath .. "/set_brightness"
    self.level = math.floor(hs.brightness.get())
end

function obj:set(level)
    level = math.max(0, math.min(100, math.floor(level + 0.5)))
    self.level = level

    local frac = string.format("%.4f", level / 100)
    if hs.fs.attributes(self.binaryPath, "mode") then
        hs.task.new(self.binaryPath, function(exitCode, _, stdErr)
            if exitCode ~= 0 then
                hs.alert.show("set_brightness failed: " .. (stdErr or ("exit " .. tostring(exitCode))), 1.5)
            end
        end, { frac }):start()
    else
        hs.brightness.set(level)
    end

    hs.alert.show("亮度 " .. level .. "%")
end

function obj:increase(step)
    self:set(self.level + (step or self.step))
end

function obj:decrease(step)
    self:set(self.level - (step or self.step))
end

function obj:bindHotkeys(mapping)
    local spec = {}
    for action in pairs(mapping or {}) do
        local level = self.defaultLevels[action]
        if level ~= nil then
            spec[action] = function() self:set(level) end
        elseif action == "increase" then
            spec[action] = function() self:increase() end
        elseif action == "decrease" then
            spec[action] = function() self:decrease() end
        end
    end
    hs.spoons.bindHotkeysToSpec(spec, mapping)
end

return obj
