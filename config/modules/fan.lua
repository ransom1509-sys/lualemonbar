local fan = {}
function fan.setup(bar)
  bar["fan"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.fgc3,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg1,
    sep     = "",
    idx     = bar.symbols.fidx,
    fmt     = "",
    sp      = bar.fmt.sp,
    icon    = bar.symbols.fan,
    cf_qstr = "",
    sf_qstr = "",
    cf_cur  = 0,
    sf_cur  = 0,
    iv      = 5,
    secs    = 0,
    show    = "",
    enabled = false,

    update = coroutine.create(function()
      local c1      = bar.fan.fgc1
      local c2      = bar.fan.fgc2
      local bc      = bar.fan.bgc
      local icon    = bar.fan.icon
      local sp      = bar.fan.sp
      local enabled = bar.fan.enabled

      while enabled do
        bar.fan.cf_cur  = bar.tools.getval(bar.fan.cf_qstr)
        bar.fan.sf_cur  = bar.tools.getval(bar.fan.sf_qstr)
        bar.fan.show = string.format("%s%s%s %s %s%4d  %4d%s",
          bc, sp, c2, icon, c1, bar.fan.cf_cur, bar.fan.sf_cur, sp)
        coroutine.yield()
      end
    end),

    init = function()
      local sf        = bar.fan.sfg
      local sb        = bar.fan.sbg
      local symbol    = bar.fan.sep
      local idx       = bar.fan.idx
      local sep       = bar.tools.separator(symbol, sf, sb, idx )
      bar.fan.sep     = sep
      bar.fan.cf_cur  = bar.tools.getval(bar.fan.cf_qstr)
      bar.fan.sf_cur  = bar.tools.getval(bar.fan.sf_qstr)
    end,

  }


  return bar

end

return fan
