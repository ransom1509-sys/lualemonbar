
local  tmp = {}
function tmp.setup(bar)
  bar["tmp"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.fgc2,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg3,
    sep     = bar.separators.tar,
    idx     = bar.symbols.fidx,
    icon    = bar.symbols.temp,
    fmt     = "",
    sp      = bar.fmt.sp,
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
      local c1      = bar.tmp.fgc1
      local c2      = bar.tmp.fgc2
      local bc      = bar.tmp.bgc
      local icon    = bar.tmp.icon
      local sp     = bar.tmp.sp

      while true do
        bar.tmp.ct_cur  = string.sub(bar.tools.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
        bar.tmp.st_cur  = string.sub(bar.tools.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
        bar.tmp.gt_cur  = string.sub(bar.tools.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
        bar.tmp.show = string.format("%s%s%s%s%s  %s  %s  %s %s",
          bc, sp, c2, icon, c1, bar.tmp.ct_cur, bar.tmp.st_cur, bar.tmp.gt_cur, sp)
        coroutine.yield()
      end
    end),

    init = function()
      local sf       = bar.tmp.sfg
      local sb       = bar.tmp.sbg
      local symbol   = bar.tmp.sep
      local idx      = bar.tmp.idx
      local sep      = bar.tools.separator(symbol, sf, sb, idx)
      bar.tmp.sep    = sep
      bar.tmp.ct_cur = string.sub(bar.tools.getval(bar.tmp.ct_qstr), 1, 2) .. "°C"
      bar.tmp.st_cur = string.sub(bar.tools.getval(bar.tmp.st_qstr), 1, 2) .. "°C"
      bar.tmp.gt_cur = string.sub(bar.tools.getprog(bar.tmp.gt_qstr), 1, 2) .. "°C"
    end,

  }

  return bar

end

return tmp
