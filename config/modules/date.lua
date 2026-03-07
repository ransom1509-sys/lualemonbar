local date = {}
function date.setup(bar)
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
      local today
      local action  = "toggle.sh rainlendar2 &"
      local bc      = bar.date.bgc
      local c1      = bar.date.fgc1
      local sep     = bar.date.sep
      while true do
        today = bar.tools.getprog(bar.date.d_fmt)
        bar.date.show = string.format("%%{T4}%s%s %%{A:%s:}%s%%{A} %%{T-}%s", bc, c1, action, today, sep)
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


  return bar

end

return date
