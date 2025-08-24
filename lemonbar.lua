#!/usr/bin/lua
-- 
--[[
Script for lemonbar-xft
From left to right:
Date - Weater - Temp (CPU. system, GPU) - Fan speed - Load - Net KiB/s - New mail - Vonnect status
]]
local posix = require("posix")

local n = 2

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
  cpu  = "",
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
    local mc, ac, cinv, cnorm, c1, c2, rxstr, txstr, symmail, symcon
    c1            = bar.colors.fgc1
    c2            = bar.colors.fgc4
    cinv          = bar.colors.inv
    cnorm         = bar.colors.fgc1
    local net     = bar.symbols.net
    local con     = bar.symbols.con
    local mail    = bar.symbols.mail
    local bc      = bar.colors.bgc1
    local sf      = bar.colors.sfg1
    local sb      = bar.colors.sbg2
    local bs      = bar.colors.bgstop
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

    return string.format("%s%s%s  %s: %s%s %s %s%s %s%s", sep, bc, c2, net, c1, rxstr, txstr, mc, mail, ac, con)

  end,

  init = function ()
    -- Make sure we start with rx = 0 KiB/s
    bar.net.rx_last = bar.func.getval(bar.net.rx_qstr)
    bar.net.tx_last = bar.func.getval(bar.net.tx_qstr)
    end
}

bar["tmp"] = {
  ct_qstr = "/sys/class/hwmon/hwmon1/temp2_input",
  st_qstr = "/sys/class/hwmon/hwmon1/temp1_input",
  gt_qstr = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits",

  c_tmp = function ()
    return string.sub(bar.func.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
  end,

  s_tmp = function ()
    return string.sub(bar.func.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
  end,

  g_tmp = function ()
    return string.sub(bar.func.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
  end,

  show = function ()
    local c1      = bar.colors.fgc1
    local c2      = bar.colors.fgc2
    local bc      = bar.colors.bgc1
    local sf      = bar.colors.sfg1
    local sb      = bar.colors.sbg3
    local bs      = bar.colors.bgstop
    local temp    = bar.symbols.temp
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    return string.format("%s%s%s  %s: %s%s  %s  %s", sep, bc, c2, temp, c1, bar.tmp.c_tmp(), bar.tmp.s_tmp(), bar.tmp.g_tmp(), bs)
  end
}

bar["fan"] = {
  cf_qstr = "/sys/class/hwmon/hwmon1/fan1_input",
  sf_qstr = "/sys/class/hwmon/hwmon1/fan2_input",

  c_fan = function ()
    return bar.func.getval(bar.fan.cf_qstr)
  end,

  s_fan = function ()
    return bar.func.getval(bar.fan.sf_qstr)
  end,

  show = function ()
    local c1      = bar.colors.fgc1
    local c2      = bar.colors.fgc3
    local cinv    = bar.colors.inv
    local cnorm   = bar.colors.fgc1
    local bc      = bar.colors.bgc1
    local sf      = bar.colors.sfg1
    local sb      = bar.colors.sbg1
    local bs      = bar.colors.bgstop
    local fan     = bar.symbols.fan
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )

    return string.format("%s%s%s  %s: %s%s  %s", sep, bc, c2, fan, c1, bar.func.pad(bar.fan.c_fan(), 4, "l", cinv, cnorm), bar.fan.s_fan())
  end
}

bar["load"] = {
  st_qstr = "/proc/stat",
  cpu_last = 0,
  cpu_last_sum = 0,

  cp_load = function ()
    local cpu_now   = {}
    local cpu_sum   = 0
    local cpu_delta = 0
    local cpu_idle  = 0
    local cpu_used  = 0
    local cpu
    local cpu_usage = 0

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
    cpu_now               = {}
    cpu_sum               = 0

    return cpu_usage

  end,

  top_cpu = function ()
    local tc_qstr = "ps -eo comm,%mem,%cpu --sort=%cpu | tail -n 1 | cut -d ' ' -f 1"
    return bar.func.getprog(tc_qstr)
  end,

  show = function ()
    local c1      = bar.colors.fgc1
    local c2      = bar.colors.fgc6
    local bc      = bar.colors.bgc2
    local sf      = bar.colors.sfg2
    local sb      = bar.colors.sbg1
    local bs      = bar.colors.bgstop
    local cinv    = bar.colors.inv
    local cpu     = bar.symbols.cpu
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )
    return string.format("%s%s%s  %s: %s%s ", sep, bc, c2, cpu, c1, bar.func.pad(bar.load.cp_load() .. "%", 3, "l", cinv, c1), bs)
  end
}

bar["date"] = {
  fgc1 = bar.colors.fgc3,
  fgc2 = bar.colors.fgc1,
  bgc  = bar.colors.bgc1,
  sfg  = bar.colors.sfg1,
  sbg  = bar.colors.sbg1,
  sep  = bar.seperators.tal,
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
  fgc1   = bar.colors.fgc1,
  fgc2   = bar.colors.fgc2,
  bgc    = bar.colors.bgc1,
  sfg    = bar.colors.sfg1,
  sbg    = bar.colors.sbg3,
  sep    = bar.seperators.tal,
  w_qstr = 'ansiweather | cut -d ":" -f 2',
  prev   = "",
  secs   = 0,

  getcur = function (int)
    local cur
    local delta

    delta = int - bar.weather.secs
    cur   = bar.weather.prev

    if delta <= 0 then
      cur = bar.func.getprog(bar.weather.w_qstr)
      bar.weather.prev = cur
      bar.weather.secs = 0
    end

    bar.weather.secs = bar.weather.secs + n

    return cur

  end,

  init = function ()
    bar.weather.prev = bar.func.getprog(bar.weather.w_qstr)
  end,

  show = function ()
    local int     = 1800
    -- local action  = 'notify-send Wetter "$(ansiweather -f 3)" &'
    -- local action  = 'zenity --info --text="$(ansiweather -f 3)" &'
    local action  = 'kitty --name "wetter" --title "wetter" -o font_size=10 wetter.sh &'
    local c1      = bar.weather.fgc1
    local bc      = bar.weather.bgc
    local sf      = bar.weather.sfg
    local sb      = bar.weather.sbg
    local bs      = bar.weather.bgstop
    local symbol  = bar.weather.sep
    local w_str   = string.format("%%{A:%s:}%s%%{A}", action, bar.weather.getcur(int))
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )
    return string.format("%s%s  %s  %s", bc, c1, w_str, sep)

  end
}

bar.init = function ()
  bar.net.init()
  bar.weather.init()
end

bar.show = function ()
  local pg = bar.colors.panelbg
  local fl = "%{l}"
  local fr = "%{r}"
  local fc = "%{c}"
  local ml = "%{O20}"
  local mr = "%{O20}"

  print(string.format("%s%s%s%s   %s%s  %s  %s  %s  %s", fl, bar.date.show(), bar.weather.show(), fr, pg, bar.tmp.show(), bar.fan.show(), bar.load.show(), bar.net.show(), bar.colors.bgstop))

end

local mybar = bar

mybar.date.bgc    = "%{B#1a1b26}"
mybar.date.sfg    = "%{F#1a1b26}"
mybar.date.sbg    = "%{B#251132}"
mybar.weather.bgc = "%{B#251132}"
mybar.weather.sfg = "%{F#251132}"
-- mybar.colors.sbg1 = "%{B#251132}"
-- mybar.colors.sfg1 = "%{F#251132}"

mybar.init()

while true do
  mybar.show()
  posix.sleep(n)
end
