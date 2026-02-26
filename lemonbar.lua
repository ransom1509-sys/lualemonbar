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
local n     = 1

local bar = {}
-- bar = {"func", "colors", "net", "tmp", "fan", "load"}
bar.timer = 1

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
  vol  = "",
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
  sep     = bar.seperators.tal,
  icon    = bar.symbols.net,
  rx_cur  = 0,
  rx_last = 0,
  tx_cur  = 0,
  tx_last = 0,
  rx_qstr = "/sys/class/net/eth1/statistics/rx_bytes",
  tx_qstr = "/sys/class/net/eth1/statistics/tx_bytes",
  nm_qstr = "claws-mail --status | cut -d ' ' -f 2",
  st_qstr = "nmcli -f STATE -t device status",
  rx_rate = 0,
  tx_rate = 0,
  status  = "",
  mails   = 0,
  secs    = 0,
  iv      = 2,

  update = function()
      --   Calculate tx in KiB/s
    bar.net.rx_cur  = bar.func.getval(bar.net.rx_qstr)
    bar.net.rx_rate = string.format("%.1f", ((bar.net.rx_cur - bar.net.rx_last) / 1024) / bar.timer)
    bar.net.rx_last = bar.net.rx_cur

    --   Calculate tx in KiB/s
    bar.net.tx_cur  = bar.func.getval(bar.net.tx_qstr)
    bar.net.tx_rate = string.format("%.1f", ((bar.net.tx_cur - bar.net.tx_last) / 1024) / bar.timer)
    bar.net.tx_last = bar.net.tx_cur

    --  Get connection status
    bar.net.status = bar.func.getprog(bar.net.st_qstr)

    --   New mails?
    bar.net.mails = tonumber(bar.func.getprog(bar.net.nm_qstr))

  end,

  show = function ()
    local mc, ac, c1, c2, rxstr, txstr
    c1            = bar.net.fgc1
    c2            = bar.net.fgc2
    local icon    = bar.net.icon
    local con     = bar.symbols.con
    local mail    = bar.symbols.mail
    local bc      = bar.net.bgc
    local sep     = bar.net.sep
    local delta   = bar.net.iv - bar.net.secs

    if delta <= 0 then
      bar.net.update()
      bar.net.secs = 0
    end

    rxstr = bar.net.rx_rate
    txstr = bar.net.tx_rate

    if bar.net.status == "connected" then
      ac = bar.colors.connected
    else
      ac = bar.colors.fgc1
    end

    if bar.net.mails ~= nil and bar.net.mails > 0 then
      mc = bar.colors.unread
    else
      mc = bar.colors.fgc1
    end

    bar.net.secs = bar.net.secs + bar.timer

    return string.format("%s%s%s %s  %s%-7.1f %-7.1f %s%s %s%s ", sep, bc, c2, icon, c1, rxstr, txstr, mc, mail, ac, con)

  end,

  init = function ()
    -- Make sure we start with rx = 0 KiB/s
    local sf        = bar.net.sfg
    local sb        = bar.net.sbg
    local symbol    = bar.seperators.tar
    local sep       = bar.func.seperator(symbol, sf, sb, 3 )
    bar.net.sep     = sep
    bar.net.rx_last = bar.func.getval(bar.net.rx_qstr)
    bar.net.tx_last = bar.func.getval(bar.net.tx_qstr)
    bar.net.status = bar.func.getprog(bar.net.st_qstr)
    bar.net.mails = tonumber(bar.func.getprog(bar.net.nm_qstr))

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
  ct_qstr = "/sys/bus/pci/drivers/k10temp/0000:00:18.3/hwmon/hwmon0/temp1_input",
  st_qstr = "/sys/class/hwmon/hwmon1/temp1_input",
  gt_qstr = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits",
  ct_cur  = '',
  st_cur  = '',
  gt_cur  = '',
  secs    = 0,
  iv      = 5,

  update  = function()
    bar.tmp.ct_cur  = string.sub(bar.func.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
    bar.tmp.st_cur  = string.sub(bar.func.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
    bar.tmp.gt_cur  = string.sub(bar.func.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
  end,

  init = function()
    local sf       = bar.tmp.sfg
    local sb       = bar.tmp.sbg
    local symbol   = bar.seperators.tar
    local sep      = bar.func.seperator(symbol, sf, sb, 3 )
    bar.tmp.sep    = sep
    bar.tmp.ct_cur = string.sub(bar.func.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
    bar.tmp.st_cur = string.sub(bar.func.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
    bar.tmp.gt_cur = string.sub(bar.func.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
  end,

  show = function ()
    local c1      = bar.tmp.fgc1
    local c2      = bar.tmp.fgc2
    local bc      = bar.tmp.bgc
    local bs      = bar.colors.bgstop
    local icon    = bar.symbols.temp
    local sep     = bar.tmp.sep
    local delta   = bar.tmp.iv - bar.tmp.secs

    if delta <= 0 then
      bar.tmp.update()
      bar.tmp.secs    = 0
    end

    bar.tmp.secs = bar.tmp.secs + bar.timer

    return string.format("%s%s%s%s  %s%s  %s  %s", sep, bc, c2, icon, c1, bar.tmp.ct_cur, bar.tmp.st_cur, bar.tmp.gt_cur, bs)
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
  cf_cur  = 0,
  sf_cur  = 0,
  iv      = 5,
  secs    = 0,

  update = function()
    bar.fan.cf_cur  = bar.func.getval(bar.fan.cf_qstr)
    bar.fan.sf_cur  = bar.func.getval(bar.fan.sf_qstr)
  end,

  init = function()
    local sf        = bar.fan.sfg
    local sb        = bar.fan.sbg
    local symbol    = bar.seperators.tar
    local sep       = bar.func.seperator(symbol, sf, sb, 3 )
    bar.fan.sep     = sep
    bar.fan.cf_cur  = bar.func.getval(bar.fan.cf_qstr)
    bar.fan.sf_cur  = bar.func.getval(bar.fan.sf_qstr)
  end,

  show = function ()
    local c1      = bar.fan.fgc1
    local c2      = bar.fan.fgc2
    local bc      = bar.fan.bgc
    local icon    = bar.symbols.fan
    local sep     = bar.fan.sep
    local delta   = bar.fan.iv - bar.fan.secs

    if delta <= 0 then
      bar.fan.update()
      bar.fan.secs    = 0
    end

    bar.fan.secs = bar.fan.secs + bar.timer

    return string.format("%s%s%s  %s  %s%4d  %4d ", sep, bc, c2, icon, c1, bar.fan.cf_cur, bar.fan.sf_cur)
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
  iv            = 5,
  secs          = 0,

  update = function ()
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
    -- cpu_now               = {}
    -- cpu_sum               = 0

    bar.load.cpu_load = cpu_usage

  end,

  show = function ()
    local c1      = bar.load.fgc1
    local c2      = bar.load.fgc2
    local bc      = bar.load.bgc
    local icon    = bar.load.icon
    local sep     = bar.load.sep
    local delta   = bar.load.iv - bar.load.secs

    if delta <= 0 then
      bar.load.update()
      bar.load.secs = 0
    end

    bar.load.secs = bar.load.secs + bar.timer

    return string.format("%s%s%s %s %s%3d%% ", sep, bc, c2, icon, c1, bar.load.cpu_load)

  end,

  init = function ()
    local sf      = bar.load.sfg
    local sb      = bar.load.sbg
    local symbol  = bar.seperators.tar
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )
    bar.load.sep  = sep
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

  init = function ()
    local sb      = bar.date.sbg
    local sf      = bar.date.sfg
    local symbol  = bar.seperators.tal
    local sep     = bar.func.seperator(symbol, sf, sb, 3 )
    bar.date.sep  = sep
  end,

  show = function ()
    local action  = "toggle.sh rainlendar2 &"
    local bc      = bar.date.bgc
    local c1      = bar.date.fgc1
    local sep     = bar.date.sep
    return string.format("%%{T4}%s%s %%{A:%s:}%s%%{A} %%{T-}%s", bc, c1, action, bar.date.getdate(), sep)
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
  iv      = 3600,
  secs    = 0,

  update = function ()
    bar.weather.cur = bar.func.getprog(bar.weather.w_qstr)
  end,

  init = function ()
    local sf        = bar.weather.sfg
    local sb        = bar.weather.sbg
    local symbol    = bar.seperators.tal
    local sep       = bar.func.seperator(symbol, sf, sb, 3 )
    bar.weather.sep = sep
    bar.weather.cur = bar.func.getprog(bar.weather.w_qstr)
  end,

  show = function ()
    -- local action  = 'notify-send Wetter "$(ansiweather -f 3)" &'
    -- local action  = 'zenity --info --text="$(ansiweather -f 3)" &'
    local action  = 'kitty --name "wetter" --title "wetter" -o font_size=10 wetter.sh &'
    -- local action  = "curl wttr.in/Berlin_lang=de.png | display"
    local c1      = bar.weather.fgc1
    local bc      = bar.weather.bgc
    local w_str   = string.format("%%{A:%s:}%s%%{A}", action, bar.weather.cur)
    local sep     = bar.weather.sep
    local delta   = bar.weather.iv - bar.weather.secs

    if delta <= 0 then
      bar.weather.update()
      bar.weather.secs = 0
    end

    bar.weather.secs = bar.weather.secs + bar.timer

    return string.format("%s%s %s %s", bc, c1, w_str, sep)

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

bar["volume"] = {
  fgc1      = bar.colors.fgc1,
  v_get_str = "pactl get-sink-volume @DEFAULT_SINK@ | cut -d ' ' -f 3",
  v_set_str = "pactl set-sink-volume @DEFAULT_SINK@ ",
  cur_vol   = 0,
  prev_vol  = 0,
  vol_up    = 0,
  vol_down  = 0,
  max_vol   = 65536,
  vol_perc  = 0,
  step      = 1310,
  icon      = bar.symbols.vol,

  update = function ()
    bar.volume.cur_vol  = bar.func.getprog(bar.volume.v_get_str)

    if bar.volume.cur_vol ~= bar.volume.prev_vol then
      bar.volume.vol_perc = 100 * bar.volume.cur_vol // bar.volume.max_vol
      bar.volume.prev_vol = bar.volume.cur_vol

      if bar.volume.cur_vol + bar.volume.step <= bar.volume.max_vol then
        bar.volume.vol_up   = bar.volume.cur_vol + bar.volume.step
      end

      if bar.volume.cur_vol - bar.volume.step >= 0 then
        bar.volume.vol_down = bar.volume.cur_vol - bar.volume.step
      end
    end

  end,

  init = function()
    bar.volume.cur_vol  = bar.func.getprog(bar.volume.v_get_str)
    bar.volume.prev_vol = bar.volume.cur_vol
    bar.volume.vol_perc = 100 * bar.volume.cur_vol // bar.volume.max_vol

    if bar.volume.cur_vol + bar.volume.step <= bar.volume.max_vol then
      bar.volume.vol_up   = bar.volume.cur_vol + bar.volume.step
    end

    if bar.volume.cur_vol - bar.volume.step >= 0 then
      bar.volume.vol_down = bar.volume.cur_vol - bar.volume.step
    end

  end,

  show = function()
    local symbol  = bar.volume.icon
    local c1      = bar.volume.fgc1
    local percent = bar.volume.vol_perc
    local action  = "pavucontrol"
    local up      = tostring(bar.volume.vol_up)
    local down    = tostring(bar.volume.vol_down)
    local inc     = bar.volume.v_set_str .. up
    local dec     = bar.volume.v_set_str .. down

    bar.volume.update()

    return string.format("%s%s %%{A1:%s:}%%{A4:%s:}%%{A5:%s:}%s%%%%{A}%%{A}%%{A}", c1, symbol, action, inc, dec, percent)
  end,
}

bar.init = function ()
  bar.tmp.init()
  bar.net.init()
  bar.fan.init()
  bar.load.init()
  bar.weather.init()
  bar.date.init()
  bar.volume.init()
end

bar.show = function ()
  local fl = "%{l}"
  local fr = "%{r}"
  local fc = "%{c}"
  local ml = "%{O20}"
  local mr = "%{O20}"

  return string.format("%s%s%s%s%s%s%s%s%s%s", fl, bar.date.show(), bar.weather.show(), bar.volume.show(), fr, bar.tmp.show(), bar.fan.show(), bar.load.show(), bar.net.show(), bar.colors.bgstop)

end

return bar
