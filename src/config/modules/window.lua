local window = {}
function window.setup(bar)
  bar["window"] = {
    fgc1    = bar.colors.fgc8,
    bgc     = "",
    fmt     = "",
    sep     = bar.separators.tar,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg3,
    sp      = bar.fmt.sp,
    w_str   = "xdotool getactivewindow getwindowname",
    show    = "",
    secs    = 0,
    iv      = 0.5,

    update = coroutine.create(function()
      local c1  = bar.window.fgc1
      local bc  = bar.window.bgc
      local sp  = bar.window.sp
      local fmt = bar.window.fmt
      local wname

      while true do
        wname = bar.tools.getprog(bar.window.w_str)
        if wname == nil then
          wname = ''
        end
          bar.window.show = string.format("%s%s%s%s %-48.48s%s", fmt, sp, c1, bc, wname, sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local sf         = bar.window.sfg
      local sb         = bar.window.sbg
      local symbol     = bar.window.sep
      local sep        = bar.tools.separator(symbol, sf, sb, 3 )
      bar.window.sep   = sep
    end
  }

  return bar

end

return window
