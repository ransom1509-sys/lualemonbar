local connect = {}

function connect.setup(bar)
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

return bar

end

return connect

