-- Package for lemonbar-xft

-- main
local lemonbar = {}

function lemonbar.setup()
  local module_table = {}
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
    look  = require("defaults")
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
      mname = mpath .. w .. ".lua"
      if bar.tools.file_exists(mname) then
        table.insert(module_table, w)
      end
    end
    for _, val in pairs(module_table) do
      mod = require(val)
      mod.setup(bar)
      mname = ""
    end
    bar.tools.mergetables(bar, conf)

    for _, val in pairs(module_table) do
      if pcall(bar[val].init) then
        bar[val].enabled = true
        if bar[val].fmt == nil then bar[val].fmt = "" end
        if bar[val].sep == nil then bar[val].sep = "" end
        coroutine.resume(bar[val].update)
      else
        bar[val].show = val .. ": error"
      end
    end

  end

  bar.show = function (lbcmd)
    local sleep, i
    local show = {}
    local cmd  = lbcmd
    local pipe_out = assert(io.popen(cmd, "w"))
    local available, socket = pcall(require, "socket")
    if available then
      sleep = socket.sleep
    else
      sleep = bar.tools.sleep
    end

    local n     = bar.settings.timer

    while true do
      i = 1
      for _, val in pairs(module_table) do
        if bar[val].iv - bar[val].secs <= 0 then
          coroutine.resume(bar[val].update)
          bar[val].secs = 0
        else
          bar[val].secs = bar[val].secs + bar.settings.timer
        end
        show[i] = bar[val].fmt
        i = i + 1
        show[i] = bar[val].show
        i = i + 1
        show[i] = bar[val].sep
        i = i + 1
      end
      pipe_out:write(table.concat(show))
      pipe_out:write("\n")
      pipe_out:flush()
      sleep(n)
    end
  end

  return bar

end

function lemonbar.init(bar)
  bar.init()
end

function lemonbar.cmd(bar)
  local cmd = bar.tools.makecmd()
  return cmd
end

function lemonbar.show(bar, cmd)
  bar.show(cmd)
end

return lemonbar
