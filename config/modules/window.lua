local window = {}
function window.setup(bar)
  bar["window"] = {
    fgc1    = bar.colors.fgc8,
    bgc     = bar.colors.bgc1,
    fmt     = "",
    sep     = bar.separators.tar,
    idx     = bar.symbols.fidx,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg3,
    sp      = bar.fmt.sp,
    width   = 64,
    format  = "",
    w_str   = "xdotool getactivewindow getwindowname",
    show    = "",
    secs    = 0,
    iv      = 0.5,

    update = coroutine.create(function()
      local c1     = bar.window.fgc1
      local bc     = bar.window.bgc
      local sp     = bar.window.sp
      local format = bar.window.format
      local wname

      while true do
        wname = bar.tools.getprog(bar.window.w_str)
        if wname == nil then
          wname = ''
        end
          bar.window.show = string.format("%s%s%s" .. format, bc, sp, c1, wname, sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local sf         = bar.window.sfg
      local sb         = bar.window.sbg
      local symbol     = bar.window.sep
      local idx        = bar.window.idx
      local sep        = bar.tools.separator(symbol, sf, sb, idx)
      local w    = bar.window.width
      local l    = bar.window.width - 4
      local f    = "-"
      local p    = "."
      local t    = "s"
      local form = string.format("%%%s%d%s%d%s", f, w, p, l, t)
      bar.window.sep    = sep
      bar.window.format = form
    end
  }

  return bar

end

return window
