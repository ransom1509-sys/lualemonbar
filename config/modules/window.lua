--Active window modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
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
    w_str   = "",
    show    = "",
    secs    = 0,
    iv      = 0.5,
    enabled = false,

    update = coroutine.create(function()
      local c1     = bar.window.fgc1
      local bc     = bar.window.bgc
      local sp     = bar.window.sp
      local format = bar.window.format
      local enabled = bar.window.enabled
      local wname
      local getprog = bar.tools.getprog

      while enabled do
        wname = getprog(bar.window.w_str)
        if wname == nil then
          wname = ''
        end
          bar.window.show = string.format("%s%s%s" .. format .."%s", bc, sp, c1, wname, sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local sf      = bar.window.sfg
      local sb      = bar.window.sbg
      local symbol  = bar.window.sep
      local idx     = bar.window.idx
      local sep     = bar.tools.separator(symbol, sf, sb, idx)
      local getprog = bar.tools.getprog
      local w       = bar.window.width
      local l       = bar.window.width - 4
      local f       = "-"
      local p       = "."
      local t       = "s"
      local form = string.format("%%%s%d%s%d%s", f, w, p, l, t)
      bar.window.sep    = sep
      bar.window.format = form
      local test = getprog(bar.window.w_str)
    end
  }

  return bar

end

return window
