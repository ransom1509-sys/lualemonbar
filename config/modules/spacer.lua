-- Spacer modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local spacer = {}
function spacer.setup(bar)
  bar["spacer"] = {
    fgc1    = "",
    bgc     = "bar.spacer.bgc",
    fmt     = "",
    sep     = "",
    idx     = "bar.spacer.idx",
    sfg     = "", 
    sbg     = "";
    sp      = "",
    width   = 4,
    format  = "",
    show    = "",
    secs    = 0,
    iv      = 86400,

    update = coroutine.create(function()
      local c1     = bar.spacer.fgc1
      local bc     = bar.spacer.bgc
      local sp     = bar.spacer.sp
      local format = bar.spacer.format

      while true do
        bar.spacer.show = string.format("%s%s%s" .. format, bc, sp, c1, " ", sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local sf         = bar.spacer.sfg
      local sb         = bar.spacer.sbg
      local symbol     = bar.spacer.sep
      local idx        = bar.symbols.fidx
      local sep        = bar.tools.separator(symbol, sf, sb, idx)
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
