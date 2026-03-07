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
  -- bar = {"func", "colors", "net", "tmp", "fan", "load"}
  bar["settings"] = {
    timer   = 1,
    init    = os.getenv("HOME") .. "/.config/lualemonbar/",
    modules = "date weather volume tmp fan load net mail connect"
  }

  bar["colors"] = {
    fgc1      = "%{F#b6c0e9}",
    fgc2      = "%{F#826bad}",
    fgc3      = "%{F#7aa2f7}",
    fgc4      = "%{F#62baad}",
    fgc5      = "%{F#99c867}",
    fgc6      = "%{F#29bdd7}",
    fgc7      = "%{F#02002f}",
    fgc8      = "%{F#ff9e64}",
    bgc1      = "%{B#1a1b26}",
    bgc2      = "%{B#414447}",
    bgc3      = "%{B#2e3c43}",
    bgc4      = "%{B#6a6f74}",
    sbg1      = "%{B#1a1b26}",
    sbg2      = "%{B#414447}",
    sbg3      = "%{B#2e3c43}",
    sbg4      = "%{B#6a6f74}",
    sfg1      = "%{F#1a1b26}",
    sfg2      = "%{F#414447}",
    sfg3      = "%{F#2e3c43}",
    sfg4      = "%{F#6a6f74}",
    unread    = "%{F#da5f8b}",
    connected = "%{F#99c867}",
    inv       = "%{F#00b6c0e5}",
    bgstop    = "%{B-}",
    fgstop    = "%{F-}",
  }

  bar["seperators"] = {
    tal = "",
    tar = "",
  }

  bar["symbols"] = {
    temp = "",
    fan  = "",
    cpu  = "", --> U+EB03 => Nerd Fonts
    -- cpu  = "",
    mail = "", -- U+E0E1 => typicons.ttf
    net  = "", -- U+E059 => typicons.ttf
    con  = "",
    wthr = "", -- U+E13B => typicons.ttf
    vol  = "",
  }

  bar["fmt"] = {
    fl = "%{l}",
    fr = "%{r}",
    fc = "%{c}",
    ml = "%{O20}",
    mr = "%{O20}",
  }

  bar["tools"] = {
    getval = function(filename)
      local fp    = assert(io.open(filename, "r"))
      local line  = fp:read("*line")
      fp:close()
      return line
    end,

    getprog = function(program)
      local prg   = assert(io.popen(program, "r"))
      local line  = prg:read("*line")
      prg:close()
      return line
    end,

    seperator = function (sep, fg, bg, index)
      local stop = bar.colors.bgstop .. bar.colors.fgstop
      local sepstr = stop .. fg .. bg .. "%{" .. "T" .. index .. "}" .. sep .. stop
      return sepstr
    end,

    file_exists = function(filename)
      local file = io.open(filename, "r")
      local exist = false
      if file then
        file:close()
        exist = true
      end
      return exist

    end,

    ini2lua = function (inif, luaf)
      local section
      local prev
      local indent  = "  "
      local inifile =  inif
      local luafile =  luaf
      local of      = assert(io.open(luafile, "w"))

      if bar.tools.file_exists(inifile) ~= true then
        return false
      end

      for line in io.lines(inifile) do
        if string.find(line, "^%[") then
          section = string.match(line,"%[(.-)%]")
          if prev ~= section and prev ~= nil then
            of:write("}\n")
          end
          of:write(section .. " = {\n")
          prev = section
        else
          of:write(indent .. line .. ",\n")
        end
      end
      of:write("}")
      of:close()
    end,

    mergetables = function(dst, src)
      for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k] or false) == "table" then
          bar.tools.mergetables(dst[k], v)
        else
          dst[k] = v
        end
      end
      return dst
    end

  }

  bar.init = function ()

    local conf          = {}
    local mods          = {}
    local mod           = {}
    -- local modules       = {}
    local path          = bar.settings.init
    local mpath         = path .. "modules/"
    local luapath       = path .. "lua/"
    local iniconf       = path .. "config.ini"
    local luaconf       = luapath .. "config.lua"
    local inimods       = path .. "modules.ini"
    local luamods       = luapath .. "modules.lua"
    local mname

    package.path = mpath .. "?.lua;" .. package.path

    -- modules = require("modules")
    -- modules.setup(bar)

    bar.tools.ini2lua(iniconf, luaconf)
    bar.tools.ini2lua(inimods, luamods)

    local i = loadfile(luaconf, "t", conf )

    if i then
      i()
    end

    local m = loadfile(luamods, "t", mods )

    if m then
      m()
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

    bar.tools.mergetables(bar, mods)

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
