-- #!/usr/bin/lua
-- 
--[[
Script for lemonbar-xft
From left to right:
Date (left click opens calendar)- Weater (left click showa forecast) - Active window - Temp (CPU. system, GPU) - Fan speed - Load - Net KiB/s - New mail - Connect status
TODO: Movef format codes to bar["formats"]
]]
-- local posix = require("posix")
-- local sleep = posix.sleep
local lemonbar = {}
local module_table = {}

function lemonbar.setup()
  local bar = {}
  bar.init = function ()

    local conf          = {}
    local mod           = {}
    local look          = {}
    local tools         = {}
    local path          = os.getenv("HOME") .. "/.config/lualemonbar/"
    local mpath         = path .. "modules/"
    local luapath       = path .. "lua/"
    local iniconf       = path .. "config.ini"
    local luaconf       = luapath .. "config.lua"
    local mname

    local package_path = package.path
    package.path = luapath .. "?.lua;" .. package_path

    -- modules = require("modules")
    -- modules.setup(bar)
    look = require("look")
    tools = require("tools")
    look.setup(bar)
    tools.setup(bar)

    package.path = mpath .. "?.lua;" .. package_path

    bar.tools.ini2lua(iniconf, luaconf)

    local i = loadfile(luaconf, "t", conf )

    if i then
      i()
    end

    bar.tools.mergetables(bar, conf)

    for w in string.gmatch(bar.settings.modules, "%S+") do
      table.insert(module_table, w)
    end

    for _, val in pairs(module_table) do
      mname = mpath .. val .. ".lua"
      if bar.tools.file_exists(mname) then
        mod = require(val)
        mod.setup(bar)
      end
      mname = ""
    end

    bar.tools.mergetables(bar, conf)

    for _, val in pairs(module_table) do
      bar[val].init()
      coroutine.resume(bar[val].update)
    end

  end

  bar.show = function (lbcmd)
    local show = ""
    local cmd  = lbcmd

    local pipe_out = assert(io.popen(cmd, "w"))

    -- local posix = require("posix")
    local socket = require("socket")
    local sleep = socket.sleep
    local n     = bar.settings.timer

    while true do
      for _, val in pairs(module_table) do
        if bar[val].iv - bar[val].secs <= 0 then
          coroutine.resume(bar[val].update)
          bar[val].secs = 0
        else
          bar[val].secs = bar[val].secs + bar.settings.timer
        end
        show = show .. bar[val].show
      end
      pipe_out:write(show .. "\n")
      pipe_out:flush()
      show = ""
      sleep(n)
    end

  end

  return bar

end

function lemonbar.init(bar)
  bar.init()
end

function lemonbar.show(bar, cmd)
  bar.show(cmd)
end

function lemonbar.debug(bar)
  local function dumptable(t, indent)
    indent = indent or ""
    local exclusion = {"function", "thread"}

    local function is_excluded(ty)
      for _, ex in ipairs(exclusion) do
          if ty == ex then return true end
      end
      return false
    end

    for k, v in pairs(t) do
      if type(v) == "table" then
        print(k .. " = " .. "{")
        bar.tools.dumptable(v, indent)
        print("}")
      else
        if not is_excluded(type(v)) then
          if type(v) == "string" then
            print(indent .. k .. " = " .. '"' .. v .. '"' .. ",")
          else
            print(indent .. k .. " = " .. v .. ",")
          end
        end
      end
    end
  end

  dumptable(bar, "  ")

end

return lemonbar
