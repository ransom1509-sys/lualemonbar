local connect = {}

function connect.setup(bar)
  bar["connect"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.connected,
    bgc     = "",
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg2,
    sep     = "",
    fmt     = "",
    sp      = bar.fmt.sp,
    icon    = bar.symbols.con,
    st_qstr = "nmcli -f STATE -t device status",
    idx     = bar.symbols.fidx,
    status  = "",
    secs    = 0,
    iv      = 2,
    show    = "";

    update = coroutine.create(function()
      local ac    = bar.connect.fgc1
      local bc    = bar.connect.bgc
      local con   = bar.connect.icon
      local sep   = bar.connect.sep
      local fmt   = bar.connect.fmt
      local sp    = bar.connect.sp
      --  Get connection status
      while true do
        bar.connect.status = bar.tools.getprog(bar.connect.st_qstr)
        if bar.connect.status == "connected" then
          ac = bar.connect.fgc2
        else
          ac = bar.connect.fgc1
        end
        bar.connect.show = string.format("%s%s%s%s%s",
          bc, sp, ac, con, sp)
        coroutine.yield()
      end
    end),

    init = function()
      local idx = bar.connect.idx
      --  Get connection status
      bar.connect.status = bar.tools.getprog(bar.connect.st_qstr)
      local sep   = bar.tools.separator(bar.connect.sep, bar.connect.sfg, bar.connect.sbg, idx)
      bar.connect.sep = sep
    end,

  }

  return bar

end

return connect

