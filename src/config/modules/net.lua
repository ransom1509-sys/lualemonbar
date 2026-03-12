
local net = {}
function net.setup(bar)
  bar["net"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.fgc4,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg2,
    sep     = bar.separators.tal,
    icon    = bar.symbols.net,
    fmt     = "",
    sp      = bar.fmt.sp,
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
      local sp      = bar.net.sp

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
        bar.net.show = string.format("%s%s%s %s  %s%-7.1f %-7.1f%s",
          bc, sp, c2, icon, c1, rxstr, txstr, sp)
        coroutine.yield()
      end
    end),

    init = function ()
      -- Make sure we start with rx = 0 KiB/s
      local sf        = bar.net.sfg
      local sb        = bar.net.sbg
      local symbol    = bar.net.sep
      local sep       = bar.tools.separator(symbol, sf, sb, 3 )
      bar.net.sep     = sep
      bar.net.rx_last = bar.tools.getval(bar.net.rx_qstr)
      bar.net.tx_last = bar.tools.getval(bar.net.tx_qstr)

    end,
  }

  return bar

end

return net
