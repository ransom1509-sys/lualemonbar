local spacer = {}
function spacer.setup(bar)
  bar["spacer"] = {
    fgc1    = bar.colors.fgc8,
    bgc     = "",
    fmt     = "",
    sep     = bar.separators.tar,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg3,
    sp      = bar.fmt.sp,
    width   = 4,
    format  = "",
    show    = "",
    secs    = 0,
    iv      = 86400,

    update = coroutine.create(function()
      local c1     = bar.spacer.fgc1
      local bc     = bar.spacer.bgc
      local sp     = bar.spacer.sp
      local fmt    = bar.spacer.fmt
      local format = bar.spacer.format

      while true do
          bar.spacer.show = string.format("%s%s%s%s" .. format, fmt, sp, c1, bc, " ", sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local sf         = bar.spacer.sfg
      local sb         = bar.spacer.sbg
      local symbol     = bar.spacer.sep
      local sep        = bar.tools.separator(symbol, sf, sb, 3 )
      local w    = bar.spacer.width
      local f    = "-"
      local t    = "s"
      local form = string.format("%%%s%d%s", f, w, t)
      bar.spacer.sep    = sep
      bar.spacer.format = form
    end
  }

  return bar

end

return spacer
