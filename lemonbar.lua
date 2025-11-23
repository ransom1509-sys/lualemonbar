#!/usr/bin/lua
-- 
--[[
Script for lemonbar-xft
From left to right:
Date - Weater - Temp (CPU. system, GPU) - Fan speed - Load - Net KiB/s - New mail - Vonnect status
TODO: Movef format codes to bar["formats"]
]]
local posix = require("posix")

local n = 1

local bar = {}
-- bar = {"func", "colors", "net", "tmp", "fan", "load"}
bar["colors"] = {
  panelbg   = "%{B#ffffff}",
  fgc1      = "%{F#b6c0e9}",
  fgc2      = "%{F#826bad}",
  fgc3      = "%{F#7aa2f7}",
  fgc4      = "%{F#62baad}",
  fgc5      = "%{F#99c867}",
  fgc6      = "%{F#29bdd7}",
  fgc7      = "%{F#02002f}",
  fgc8      = "%{F#ff9e64}",
  bgc1      = "%{B#2e3c43}",
  bgc2      = "%{B#414447}",
  bgc3      = "%{B#1a1b26}",
  bgc4      = "%{B#6a6f74}",
  sbg1      = "%{B#2e3c43}",
  sbg2      = "%{B#414447}",
  sbg3      = "%{B#1a1b26}",
  sbg4      = "%{B#6a6f74}",
  sfg1      = "%{F#2e3c43}",
  sfg2      = "%{F#414447}",
  sfg3      = "%{F#1a1b26}",
  sfg4      = "%{F#6a6f74}",
  unread    = "%{F#da5f8b}",
  connected = "%{F#99c867}",
  inv       = "%{F#00b6c0e5}",
  bgstop    = "%{B-}",
  fgstop    = "%{F-}",
}

bar["seperators"] = {
  tal = "",
  tar = "",
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
}

bar["func"] = {
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

  -- Padding with invisible "0"s
  -- Dirty hack for propotional font to avoid jumpy columns
  -- Works only for numbers
  pad = function (padstr, len, side, cinv, cnorm)
    if string.len(padstr) > len then
      padstr = string.sub(padstr, 1, len)
    end

    local chrlen = len - string.len(padstr)

    if chrlen > 0 then
      if side == "l" then
        padstr = padstr .. cinv .. string.rep(" ", chrlen) .. cnorm
      end
      if side == "r" then
        padstr = cinv .. string.rep("0", chrlen) .. cnorm .. padstr
      end

    end

    return padstr

  end,

  seperator = function (sep, fg, bg, index)
    local stop = bar.colors.bgstop .. bar.colors.fgstop
    local sepstr = stop .. fg .. bg .. "%{" .. "T" .. index .. "}" .. sep .. stop
    return sepstr
  end
}

bar["net"] = {
  fgc1    = bar.colors.fgc1,
  fgc2    = bar.colors.fgc4,
  bgc     = bar.colors.bgc1,
  sfg     = bar.colors.sfg1,
  sbg     = bar.colors.sbg2,
  sep     = bar.seperators.tar,
  icon    = bar.symbols.net,
  rx_cur  = 0,
  rx_last = 0,
  tx_cur  = 0,
  tx_last = 0,
  rx_qstr = "/sys/class/net/eth1/statistics/rx_bytes",
  tx_qstr = "/sys/class/net/eth1/statistics/tx_bytes",
  nm_qstr = "claws-mail --status | cut -d ' ' -f 2",
  st_qstr = "nmcli -f STATE -t device status",

  -- Calculate rx in KiB/s
  rx_per_s = function()
    bar.net.rx_cur  = bar.func.getval(bar.net.rx_qstr)
    local rx_rate   = string.format("%.1f", ((bar.net.rx_cur - bar.net.rx_last) / 1024) / n)
    bar.net.rx_last = bar.net.rx_cur
    return rx_rate
  end,

  -- Calculate tx in KiB/s
  tx_per_s = function()
    bar.net.tx_cur  = bar.func.getval(bar.net.tx_qstr)
    local tx_rate   = string.format("%.1f", ((bar.net.tx_cur - bar.net.tx_last) / 1024) / n)
    bar.net.tx_last = bar.net.tx_cur
    return tx_rate
  end,

  --Get connection status
  status = function()
    return bar.func.getprog(bar.net.st_qstr)
  end,

  -- New mails?
  mails = function ()
    return tonumber(bar.func.getprog(bar.net.nm_qstr))
  end,

  show = function ()
    local mc, ac, cinv, cnorm, c1, c2, rxstr, txstr
    c1            = bar.net.fgc1
    c2            = bar.net.fgc2
    cinv          = bar.colors.inv
    cnorm         = bar.net.fgc1
    local icon    = bar.net.icon
    local con     = bar.symbols.con
    local mail    = bar.symbols.mail
    local bc      = bar.net.bgc
    local sf      = bar.net.sfg
    local sb      = bar.net.sbg
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    rxstr = bar.func.pad(bar.net.rx_per_s(), 7, "l", cinv, cnorm)
    txstr = bar.func.pad(bar.net.tx_per_s(), 7, "l", cinv, cnorm)

    if bar.net.status() == "connected" then
      ac = bar.colors.connected
    else
      ac = bar.colors.fgc1
    end

    if bar.net.mails() ~= nil and bar.net.mails() > 0 then
      mc = bar.colors.unread
    else
      mc = bar.colors.fgc1
    end

    return string.format("%s%s%s  %s  %s%s %s %s%s %s%s", sep, bc, c2, icon, c1, rxstr, txstr, mc, mail, ac, con)

  end,

  init = function ()
    -- Make sure we start with rx = 0 KiB/s
    bar.net.rx_last = bar.func.getval(bar.net.rx_qstr)
    bar.net.tx_last = bar.func.getval(bar.net.tx_qstr)
    end
}

bar["tmp"] = {
  fgc1    = bar.colors.fgc1,
  fgc2    = bar.colors.fgc2,
  bgc     = bar.colors.bgc1,
  sfg     = bar.colors.sfg1,
  sbg     = bar.colors.sbg3,
  sep     = bar.seperators.tar,
  icon    = bar.symbols.temp,
  ct_qstr = "/sys/class/hwmon/hwmon1/temp2_input",
  st_qstr = "/sys/class/hwmon/hwmon1/temp1_input",
  gt_qstr = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits",
  ct_cur  = '',
  st_cur  = '',
  gt_cur  = '',
  secs    = 0,
  iv      = 5,

  update  = function(int)
    local delta
    delta = int - bar.tmp.secs

    if delta <= 0 then
      bar.tmp.ct_cur  = string.sub(bar.func.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
      bar.tmp.st_cur  = string.sub(bar.func.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
      bar.tmp.gt_cur  = string.sub(bar.func.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
      bar.tmp.secs    = 0
    end

    bar.tmp.secs = bar.tmp.secs + n

  end,

  init = function()
    bar.tmp.ct_cur = string.sub(bar.func.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
    bar.tmp.st_cur = string.sub(bar.func.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
    bar.tmp.gt_cur = string.sub(bar.func.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
  end,

  show = function ()
    local c1      = bar.tmp.fgc1
    local c2      = bar.tmp.fgc2
    local bc      = bar.tmp.bgc
    local sf      = bar.tmp.sfg
    local sb      = bar.tmp.sbg
    local bs      = bar.colors.bgstop
    local icon    = bar.symbols.temp
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    bar.tmp.update(bar.tmp.iv)

    return string.format("%s%s%s  %s  %s%s  %s  %s", sep, bc, c2, icon, c1, bar.tmp.ct_cur, bar.tmp.st_cur, bar.tmp.gt_cur, bs)
  end
}

bar["fan"] = {
  fgc1    = bar.colors.fgc1,
  fgc2    = bar.colors.fgc3,
  bgc     = bar.colors.bgc1,
  sfg     = bar.colors.sfg1,
  sbg     = bar.colors.sbg1,
  sep     = bar.seperators.tar,
  icon    = bar.symbols.fan,
  cf_qstr = "/sys/class/hwmon/hwmon1/fan1_input",
  sf_qstr = "/sys/class/hwmon/hwmon1/fan2_input",
  cf_cur  = '',
  sf_cur  = '',
  iv      = 5,
  secs    = 0,

  update = function(int)
    local delta

    delta = int - bar.fan.secs

    if delta <= 0 then
      bar.fan.cf_cur  = bar.func.getval(bar.fan.cf_qstr)
      bar.fan.sf_cur  = bar.func.getval(bar.fan.sf_qstr)
      bar.fan.secs    = 0
    end

    bar.fan.secs = bar.fan.secs + n

  end,

  init = function()
    bar.fan.cf_cur  = bar.func.getval(bar.fan.cf_qstr)
    bar.fan.sf_cur  = bar.func.getval(bar.fan.sf_qstr)
  end,

  show = function ()
    local c1      = bar.fan.fgc1
    local c2      = bar.fan.fgc2
    local cnorm   = bar.fan.fgc1
    local bc      = bar.fan.bgc
    local sf      = bar.fan.sfg
    local sb      = bar.fan.sbg
    local cinv    = bar.colors.inv
    local icon    = bar.symbols.fan
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    bar.fan.update(bar.fan.iv)

    return string.format("%s%s%s  %s  %s%s  %s", sep, bc, c2, icon, c1, bar.func.pad(bar.fan.cf_cur, 4, "l", cinv, cnorm), bar.fan.sf_cur)
  end
}

bar["load"] = {
  fgc1          = bar.colors.fgc1,
  fgc2          = bar.colors.fgc6,
  bgc           = bar.colors.bgc2,
  sfg           = bar.colors.sfg2,
  sbg           = bar.colors.sbg1,
  sep           = bar.seperators.tar,
  icon          = bar.symbols.cpu,
  st_qstr       = "/proc/stat",
  cpu_last      = 0,
  cpu_last_sum  = 0,
  cpu_load      = 0,
  iv            = 2,
  secs          = 0,

  update = function (int)
    local cpu_now   = {}
    local cpu_sum   = 0
    local cpu_delta = 0
    local cpu_idle  = 0
    local cpu_used  = 0
    local cpu
    local cpu_usage = 0
    local delta

    delta = int - bar.load.secs

    if delta <= 0 then
    -- get cpu stats
      cpu = bar.func.getval(bar.load.st_qstr)

      -- Convert string to table
      for w in string.gmatch(cpu, "[^%s]+") do
        table.insert(cpu_now, w)
      end

      -- Sum up all fields, skip first with "cpu" in it
      for key, val in pairs(cpu_now) do
        if key > 1 then
          cpu_sum = cpu_sum + val
        end
      end

      -- Calculate cpu usage
      cpu_delta   = cpu_sum - bar.load.cpu_last_sum
      cpu_idle    = cpu_now[5] - bar.load.cpu_last
      cpu_used    = cpu_delta - cpu_idle
      cpu_usage   = 100 * cpu_used // cpu_delta

      -- Store values for compare, re-initialize vars for next run
      bar.load.cpu_last     = cpu_now[5]
      bar.load.cpu_last_sum = cpu_sum
      -- cpu_now               = {}
      -- cpu_sum               = 0

      bar.load.cpu_load = cpu_usage
      bar.load.secs = 0

    end

    bar.load.secs = bar.load.secs + n

  end,

  show = function ()
    local c1      = bar.load.fgc1
    local c2      = bar.load.fgc2
    local bc      = bar.load.bgc
    local sf      = bar.load.sfg
    local sb      = bar.load.sbg
    local bs      = bar.colors.bgstop
    local cinv    = bar.colors.inv
    local icon    = bar.load.icon
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    bar.load.update(bar.load.iv)

    return string.format("%s%s%s  %s  %s%s ", sep, bc, c2, icon, c1, bar.func.pad(bar.load.cpu_load .. "%", 3, "l", cinv, c1), bs)

  end
}

bar["date"] = {
  fgc1    = bar.colors.fgc3,
  fgc2    = bar.colors.fgc1,
  bgc     = bar.colors.bgc1,
  sfg     = bar.colors.sfg1,
  sbg     = bar.colors.sbg1,
  sep     = bar.seperators.tal,
  getdate = function ()
    local d = bar.func.getprog('date +"%a %d.%m.%Y %H:%M"')
    return d
  end,

  show = function ()
    local action  = "toggle.sh rainlendar2 &"
    local bc      = bar.date.bgc
    local sb      = bar.date.sbg
    local sf      = bar.date.sfg
    local c1      = bar.date.fgc1
    local symbol  = bar.seperators.tal
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )
    return string.format("%s%s  %%{A:%s:}%s%%{A}  %s", bc, c1, action, bar.date.getdate(), sep)
  end

}

bar["weather"] = {
  -- w_qstr = "curl -H 'Cache-Control: no-cache, no-store' wttr.in/txl?format=%t",
  -- w_qstr = "curl wttr.in/-Brandenburger+Gate?format=%t",
  fgc1    = bar.colors.fgc1,
  fgc2    = bar.colors.fgc2,
  bgc     = bar.colors.bgc1,
  sfg     = bar.colors.sfg1,
  sbg     = bar.colors.sbg3,
  sep     = bar.seperators.tal,
  icon    = "",
  w_qstr  = 'ansiweather | cut -d ":" -f 2',
  cur     = "",
  iv      = 1800,
  secs    = 0,

  update = function (int)
    local delta

    delta = int - bar.weather.secs

    if delta <= 0 then
      bar.weather.cur = bar.func.getprog(bar.weather.w_qstr)
      bar.weather.secs = 0
    end

    bar.weather.secs = bar.weather.secs + n

  end,

  init = function ()
    bar.weather.cur = bar.func.getprog(bar.weather.w_qstr)
  end,

  show = function ()
    -- local action  = 'notify-send Wetter "$(ansiweather -f 3)" &'
    -- local action  = 'zenity --info --text="$(ansiweather -f 3)" &'
    local action  = 'kitty --name "wetter" --title "wetter" -o font_size=10 wetter.sh &'
    local c1      = bar.weather.fgc1
    local bc      = bar.weather.bgc
    local sf      = bar.weather.sfg
    local sb      = bar.weather.sbg
    local symbol  = bar.seperators.tal
    local w_str   = string.format("%%{A:%s:}%s%%{A}", action, bar.weather.cur)
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    bar.weather.update(bar.weather.iv)

    return string.format("%s%s  %s  %s", bc, c1, w_str, sep)

  end
}

bar["window"] = {
  fgc1    = bar.colors.fgc8,
  w_str   = "xdotool getactivewindow getwindowname",

  show = function()
    local c1 = bar.window.fgc1
    local wname = bar.func.getprog(bar.window.w_str)
    if wname ~= nil then
      return string.format("%s%s", c1, wname)
    else return ''
    end
  end
}

bar.init = function ()
  bar.tmp.init()
  bar.net.init()
  bar.fan.init()
  bar.weather.init()
end

bar.show = function ()
  local fl = "%{l}"
  local fr = "%{r}"
  local fc = "%{c}"
  local ml = "%{O20}"
  local mr = "%{O20}"

  print(string.format("%s%s%s    %s    %s  %s  %s  %s  %s  %s", fl, bar.date.show(), bar.weather.show(), bar.window.show(), fr, bar.tmp.show(), bar.fan.show(), bar.load.show(), bar.net.show(), bar.colors.bgstop))

end

-- ************* Overwriting defaults *************

local mybar = bar
mybar.colors.bgc5 = "%{B#222332}"
mybar.colors.sbg5 = "%{B#222332}"
mybar.colors.sfg5 = "%{F#222332}"
mybar.colors.bgc1 = "%{B#2d3246}"
mybar.colors.sbg1 = "%{B#2d3246}"
mybar.colors.sfg1 = "%{F#2d3246}"

-- mybar.date.fgc1   = mybar.colors.fgc1
mybar.date.bgc    = mybar.colors.bgc5
mybar.date.sfg    = mybar.colors.sfg5
mybar.date.sbg    = mybar.colors.bgc1
mybar.tmp.bgc     = mybar.colors.bgc1
mybar.tmp.sfg     = mybar.colors.sfg1
mybar.tmp.sbg     = mybar.colors.sbg3
mybar.tmp.bgc     = mybar.colors.bgc1
mybar.tmp.sfg     = mybar.colors.sfg1
mybar.weather.sbg = mybar.colors.sbg3
mybar.weather.sfg = mybar.colors.sfg1
mybar.weather.bgc = mybar.colors.bgc1
mybar.net.bgc     = mybar.colors.bgc5
mybar.net.sfg     = mybar.colors.sfg5
mybar.net.sbg     = mybar.colors.sbg1
mybar.fan.bgc     = mybar.colors.bgc5
mybar.fan.sfg     = mybar.colors.sfg5
mybar.fan.sbg     = mybar.colors.sbg1
mybar.load.bgc    = mybar.colors.bgc1
mybar.load.sfg    = mybar.colors.sfg1
mybar.load.sbg    = mybar.colors.sbg5


--[[
for k, v in pairs(mybar) do
  if type(v) == "table" then
    for key, val in pairs(v) do
      if key == "bgc" then
        mybar[k][key] = "%{B#ffffff}"
      end
    end
  end
end
]]

mybar.init()

while true do
  mybar.show()
  -- print(string.format("DEBUG: %s", mybar.load.secs))
  posix.sleep(n)
end
