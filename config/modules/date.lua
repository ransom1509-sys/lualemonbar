local date = {}
function date.setup(bar)
  bar["date"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.fgc1,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg1,
    sep     = "",
    idx     = bar.symbols.fidx,
    sp      = bar.fmt.sp,
    fmt     = "",
    d_fmt   = "date +'%a %d:%m:%Y %H.%M'",
    action  = "",
    iv      = 60,
    secs    = 0;
    show    = "",
    enabled = false,
    update  = coroutine.create(function ()
      local today
      local action  = bar.date.action
      local bc      = bar.date.bgc
      local c1      = bar.date.fgc1
      local sp      = bar.date.sp
      local enabled = bar.date.enabled

      while enabled do
        today = bar.tools.getprog(bar.date.d_fmt)
        bar.date.show = string.format("%s%s%s %%{A:%s:}%s%%{A}%s",
          bc, sp, c1, action, today, sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local idx     = bar.date.idx
      local sb      = bar.date.sbg
      local sf      = bar.date.sfg
      local symbol  = bar.date.sep
      local sep     = bar.tools.separator(symbol, sf, sb, idx)
      bar.date.sep  = sep
      bar.tools.getprog(bar.date.d_fmt)
    end,

  }

  return bar

end

return date
