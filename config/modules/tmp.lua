
local  tmp = {}
function tmp.setup(bar)
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

  return bar

end

return tmp
