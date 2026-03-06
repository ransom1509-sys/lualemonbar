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

      ini2lua = function ()
        local section
        local prev
        local indent  = "  "
        local inifile = bar.settings.init .. "config.ini"
        local luafile = bar.settings.init .. "config.lua"
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

    bar["connect"] = {
      fgc1    = bar.colors.fgc1,
      fgc2    = bar.colors.connected,
      bgc     = bar.colors.bgc1,
      sfg     = bar.colors.sfg1,
      sbg     = bar.colors.sbg2,
      sep     = bar.seperators.tal,
      icon    = bar.symbols.con,
      st_qstr = "nmcli -f STATE -t device status",
      status  = "",
      secs    = 0,
      iv      = 2,
      show    = "";

      update = coroutine.create(function()
        local ac    = bar.connect.fgc1
        local bc    = bar.connect.bgc
        local con   = bar.connect.icon
        local sep   = bar.tools.seperator(bar.connect.sep, bar.connect.sfg, bar.connect.sbg, 3)
        --  Get connection status
        while true do
          bar.connect.status = bar.tools.getprog(bar.connect.st_qstr)
          if bar.connect.status == "connected" then
            ac = bar.connect.fgc2
          else
            ac = bar.connect.fgc1
          end

          bar.connect.show = string.format("%s%s%s%s ", sep, bc, ac, con)
          coroutine.yield()
        end
      end),

      init = function()
        --  Get connection status
        bar.connect.status = bar.tools.getprog(bar.connect.st_qstr)
      end,

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
      rx_rate = 0,
      tx_rate = 0,
      secs    = 0,
      iv      = 2,
      show    = "",

      update = coroutine.create(function()
        local c1, c2, rxstr, txstr
        c1            = bar.net.fgc1
        c2            = bar.net.fgc2
        local icon    = bar.net.icon
        local bc      = bar.net.bgc
        local sep     = bar.net.sep
        local fmt     = bar.fmt.fr

        while true do
          --   Calculate tx in keyiB/s
          bar.net.rx_cur  = bar.tools.getval(bar.net.rx_qstr)
          bar.net.rx_rate = string.format("%.1f", ((bar.net.rx_cur - bar.net.rx_last) / 1024) / bar.settings.timer)
          bar.net.rx_last = bar.net.rx_cur
          --   Calculate tx in KiB/s
          bar.net.tx_cur  = bar.tools.getval(bar.net.tx_qstr)
          bar.net.tx_rate = string.format("%.1f", ((bar.net.tx_cur - bar.net.tx_last) / 1024) / bar.settings.timer)
          bar.net.tx_last = bar.net.tx_cur
          rxstr = bar.net.rx_rate
          txstr = bar.net.tx_rate
          bar.net.show = string.format("%s%s%s%s %s  %s%-7.1f %-7.1f ", fmt, sep, bc, c2, icon, c1, rxstr, txstr)
          coroutine.yield()
        end
      end),

      init = function ()
        -- Make sure we start with rx = 0 KiB/s
        local sf        = bar.net.sfg
        local sb        = bar.net.sbg
        local symbol    = bar.seperators.tar
        local sep       = bar.tools.seperator(symbol, sf, sb, 3 )
        bar.net.sep     = sep
        bar.net.rx_last = bar.tools.getval(bar.net.rx_qstr)
        bar.net.tx_last = bar.tools.getval(bar.net.tx_qstr)

      end,
    }

    bar["mail"] = {
      fgc1    = bar.colors.fgc1,
      fgc2    = bar.colors.unread,
      bgc     = bar.colors.bgc1,
      sfg     = bar.colors.sfg1,
      sbg     = bar.colors.sbg2,
      sep     = bar.seperators.tal,
      icon    = bar.symbols.mail,
      nm_qstr = "claws-mail --status | cut -d ' ' -f 2",
      secs    = 0,
      iv      = 2,
      show    = "",

      update = coroutine.create(function ()
        local c1    = bar.mail.fgc1
        local c2    = bar.mail.fgc2
        local mc    = bar.mail.fgc1
        local bc    = bar.mail.bgc
        local mail  = bar.mail.icon
        local sep   = bar.tools.seperator(bar.mail.sep, bar.mail.sfg, bar.mail.sbg, 3)
        while true do
          --   New mails?
          bar.mail.mails = tonumber(bar.tools.getprog(bar.mail.nm_qstr))
          if bar.mail.mails ~= nil and bar.mail.mails > 0 then
            mc = c2
          else
            mc = c1
          end

          bar.mail.show = string.format(" %s%s%s%s ", sep, bc, mc, mail)
          coroutine.yield()
        end
      end),

      init = function ()
        bar.mail.mails = tonumber(bar.tools.getprog(bar.mail.nm_qstr))
      end,

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
      show    = "",

      update  = coroutine.create(function()
        local sf        = bar.fan.sfg
        local sb        = bar.fan.sbg
        local c1      = bar.tmp.fgc1
        local c2      = bar.tmp.fgc2
        local bc      = bar.tmp.bgc
        local bs      = bar.colors.bgstop
        local icon    = bar.symbols.temp
        local symbol  = bar.seperators.tar
        local sep     = bar.tools.seperator(symbol, sf, sb, 3 )
        local fmt      = bar.fmt.fc

        while true do
          bar.tmp.ct_cur  = string.sub(bar.tools.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
          bar.tmp.st_cur  = string.sub(bar.tools.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
          bar.tmp.gt_cur  = string.sub(bar.tools.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
          bar.tmp.show = string.format("%s%s%s%s%s  %s%s  %s  %s", fmt, sep, bc, c2, icon, c1, bar.tmp.ct_cur, bar.tmp.st_cur, bar.tmp.gt_cur, bs)
        coroutine.yield()
        end
      end),

      init = function()
        local sf       = bar.tmp.sfg
        local sb       = bar.tmp.sbg
        local symbol   = bar.seperators.tar
        local sep      = bar.tools.seperator(symbol, sf, sb, 3 )
        bar.tmp.sep    = sep
        bar.tmp.ct_cur = string.sub(bar.tools.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
        bar.tmp.st_cur = string.sub(bar.tools.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
        bar.tmp.gt_cur = string.sub(bar.tools.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
      end,

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
      show    = "",

      update = coroutine.create(function()
        local c1      = bar.fan.fgc1
        local c2      = bar.fan.fgc2
        local bc      = bar.fan.bgc
        local icon    = bar.symbols.fan
        local sep     = bar.fan.sep

        while true do
          bar.fan.cf_cur  = bar.tools.getval(bar.fan.cf_qstr)
          bar.fan.sf_cur  = bar.tools.getval(bar.fan.sf_qstr)
          bar.fan.show = string.format("%s%s%s  %s  %s%4d  %4d ", sep, bc, c2, icon, c1, bar.fan.cf_cur, bar.fan.sf_cur)
        coroutine.yield()
        end
      end),

      init = function()
        local sf        = bar.fan.sfg
        local sb        = bar.fan.sbg
        local symbol    = bar.seperators.tar
        local sep       = bar.tools.seperator(symbol, sf, sb, 3 )
        bar.fan.sep     = sep
        bar.fan.cf_cur  = bar.tools.getval(bar.fan.cf_qstr)
        bar.fan.sf_cur  = bar.tools.getval(bar.fan.sf_qstr)
      end,

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
      show          = "",

      update = coroutine.create(function ()
        local cpu_now   = {}
        local cpu_sum   = 0
        local cpu_delta = 0
        local cpu_idle  = 0
        local cpu_used  = 0
        local cpu
        local c1      = bar.load.fgc1
        local c2      = bar.load.fgc2
        local bc      = bar.load.bgc
        local icon    = bar.load.icon
        local sep     = bar.load.sep
        local cpu_usage = 0

        while true do
          -- get cpu stats
          cpu_now = {}
          cpu_sum   = 0
          cpu_delta = 0
          cpu_idle  = 0
          cpu_used  = 0

          cpu = bar.tools.getval(bar.load.st_qstr)
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

          bar.load.show = string.format("%s%s%s %s %s%3d%% ", sep, bc, c2, icon, c1, bar.load.cpu_load)
        coroutine.yield()
        end
      end),


      init = function ()
        local sf      = bar.load.sfg
        local sb      = bar.load.sbg
        local symbol  = bar.seperators.tar
        local sep     = bar.tools.seperator(symbol, sf, sb, 3 )
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
      d_fmt   = "date +'%a %d:%m:%Y %H.%M'",
      iv      = 60,
      secs    = 0;
      show    = "",
      update  = coroutine.create(function ()
        local date
        local action  = "toggle.sh rainlendar2 &"
        local bc      = bar.date.bgc
        local c1      = bar.date.fgc1
        local sep     = bar.date.sep
        while true do
          date = bar.tools.getprog(bar.date.d_fmt)
          bar.date.show = string.format("%%{T4}%s%s %%{A:%s:}%s%%{A} %%{T-}%s", bc, c1, action, date, sep)
          coroutine.yield()
        end
      end),

      init = function ()
        local sb      = bar.date.sbg
        local sf      = bar.date.sfg
        local symbol  = bar.seperators.tal
        local sep     = bar.tools.seperator(symbol, sf, sb, 3 )
        bar.date.sep  = sep
      end,

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
      w_qstr  = "ansiweather | cut -d ':' -f 2",
      cur     = "",
      iv      = 3600,
      secs    = 0,
      show    = "",

      update = coroutine.create(function ()
        local action  = "kitty --name 'wetter' --title 'wetter' -o font_size=10 wetter.sh &"
        local c1      = bar.weather.fgc1
        local bc      = bar.weather.bgc
        local w_str   = string.format("%%{A:%s:}%s%%{A}", action, bar.weather.cur)
        local sep     = bar.weather.sep

        while true do
          bar.weather.cur = bar.tools.getprog(bar.weather.w_qstr)
          bar.weather.show = string.format("%s%s %s %s", bc, c1, w_str, sep)
          coroutine.yield()
        end
      end),

      init = function ()
        local sf        = bar.weather.sfg
        local sb        = bar.weather.sbg
        local symbol    = bar.seperators.tal
        local sep       = bar.tools.seperator(symbol, sf, sb, 3 )
        bar.weather.sep = sep
        bar.weather.cur = bar.tools.getprog(bar.weather.w_qstr)
      end,

    }

    bar["window"] = {
      fgc1    = bar.colors.fgc8,
      w_str   = "xdotool getactivewindow getwindowname",
      show    = "",

      update = coroutine.create(function()
        local c1 = bar.window.fgc1
        local wname
        while true do
          wname = bar.tools.getprog(bar.window.w_str)
          if wname ~= nil then
            bar.window.show = string.format("%s%s", c1, wname)
          else
            bar.window.show = ''
          end
          coroutine.yield()
        end
      end),

      init = function ()
        bar.window.update()
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
      secs      = 0,
      iv        = 2,
      show      = "",

      update = coroutine.create(function ()
        local symbol  = bar.volume.icon
        local c1      = bar.volume.fgc1
        local percent = bar.volume.vol_perc
        local action  = "pavucontrol"
        local up      = tostring(bar.volume.vol_up)
        local down    = tostring(bar.volume.vol_down)
        local inc     = bar.volume.v_set_str .. up
        local dec     = bar.volume.v_set_str .. down

        while true do
          bar.volume.cur_vol  = bar.tools.getprog(bar.volume.v_get_str)

          -- if bar.volume.cur_vol ~= bar.volume.prev_vol then
          bar.volume.vol_perc = 100 * bar.volume.cur_vol // bar.volume.max_vol
          percent = bar.volume.vol_perc
          -- bar.volume.prev_vol = bar.volume.cur_vol

          if bar.volume.cur_vol + bar.volume.step <= bar.volume.max_vol then
            bar.volume.vol_up   = bar.volume.cur_vol + bar.volume.step
          end

          if bar.volume.cur_vol - bar.volume.step >= 0 then
            bar.volume.vol_down = bar.volume.cur_vol - bar.volume.step
          end
          -- end
          up   = tostring(bar.volume.vol_up)
          down = tostring(bar.volume.vol_down)
          inc  = bar.volume.v_set_str .. up
          dec  = bar.volume.v_set_str .. down

          bar.volume.show = string.format("%s%s %%{A1:%s:}%%{A4:%s:}%%{A5:%s:}%s%%%%{A}%%{A}%%{A}", c1, symbol, action, inc, dec, percent)
          coroutine.yield()
        end
      end),

      init = function()
        bar.volume.cur_vol  = bar.tools.getprog(bar.volume.v_get_str)
        bar.volume.prev_vol = bar.volume.cur_vol
        bar.volume.vol_perc = 100 * bar.volume.cur_vol // bar.volume.max_vol

        if bar.volume.cur_vol + bar.volume.step <= bar.volume.max_vol then
          bar.volume.vol_up   = bar.volume.cur_vol + bar.volume.step
        end

        if bar.volume.cur_vol - bar.volume.step >= 0 then
          bar.volume.vol_down = bar.volume.cur_vol - bar.volume.step
        end

      end,

    }

    bar.init = function ()

      local conf = {}
      local mods = {}
      local pathname = bar.settings.init .. "modules/"
      local mname
      package.path = pathname .. "?.lua" .. ";" .. package.path

      bar.tools.ini2lua()
      local f, err = loadfile(bar.settings.init .. "config.lua", "t", conf )

      if f then
        f()
      end

      bar.tools.mergetables(bar, conf)

      for w in string.gmatch(bar.settings.modules, "%S+") do
        table.insert(module_table, w)
      end

      for key, val in pairs(module_table) do
        mname = pathname .. val .. ".lua"
        if bar.tools.file_exists(mname) then
          mods = require(val)
          bar.tools.mergetables(bar, mods)
        end
        mname = ""
      end

      for key, val in pairs(module_table) do
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
        for key, val in pairs(module_table) do
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

return lemonbar
