
-- Net traffic modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local net = {}
function net.setup(bar)
  bar["net"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.connected,
    fgc3    = bar.colors.unconnect,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg2,
    sep     = bar.separators.tal,
    idx     = bar.symbols.fidx,
    icon    = bar.symbols.net,
    fmt     = "",
    sp      = bar.fmt.sp,
    rx_cur  = 0,
    rx_last = 0,
    tx_cur  = 0,
    tx_last = 0,
    rx_qstr = "",
    tx_qstr = "",
    rx_rate = 0,
    tx_rate = 0,
    st_qstr = "",
    status  = "",
    secs    = 0,
    iv      = 2,
    enabled = false,
    show    = "",

    update = coroutine.create(function()
      local c1, c2, rxstr, txstr
      c1            = bar.net.fgc1
      c2            = bar.net.fgc2
      local icon    = bar.net.icon
      local bc      = bar.net.bgc
      local sp      = bar.net.sp
      local enabled = bar.net.enabled

      while enabled do
        bar.net.status = bar.tools.getprog(bar.net.st_qstr)
        if bar.net.status == "connected" then
          c2 = bar.net.fgc2
          c1 = bar.net.fgc1
        else
          c2 = bar.net.fgc3
          c1 = bar.net.fgc3
        end
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
      local idx       = bar.net.idx
      local sep       = bar.tools.separator(symbol, sf, sb, idx)
      bar.net.sep     = sep
      bar.net.status = bar.tools.getprog(bar.net.st_qstr)
      bar.net.rx_last = bar.tools.getval(bar.net.rx_qstr)
      bar.net.tx_last = bar.tools.getval(bar.net.tx_qstr)

    end,
  }

  return bar

end

return net
