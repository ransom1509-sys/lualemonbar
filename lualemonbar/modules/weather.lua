-- Wether modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local weather = {}
function weather.setup(bar)
  bar["weather"] = {
    -- w_qstr = "curl -H 'Cache-Control: no-cache, no-store' wttr.in/txl?format=%t",
    -- w_qstr = "curl wttr.in/-Brandenburger+Gate?format=%t",
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.fgc2,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg3,
    sep     = bar.separators.tar,
    idx     = bar.symbols.fidx,
    fmt     = "",
    sp      = "",
    icon    = "",
    w_qstr  = "",
    action  = "",
    cur     = "",
    iv      = 1800,
    secs    = 0,
    show    = "",
    enabled = false,

    update = coroutine.create(function ()
      local action  = bar.weather.action
      local c1      = bar.weather.fgc1
      local bc      = bar.weather.bgc
      local w_str   = string.format("%%{A:%s:}%s%%{A}", action, bar.weather.cur)
      local sp      = bar.weather.sp
      local enabled = bar.weather.enabled

      while enabled do
        bar.weather.cur = bar.tools.getprog(bar.weather.w_qstr)
        bar.weather.show = string.format("%s%s%s%s%s", bc, sp, c1, w_str, sp)
        coroutine.yield()
      end
    end),

    init = function ()
      local sf        = bar.weather.sfg
      local sb        = bar.weather.sbg
      local symbol    = bar.weather.sep
      local idx       = bar.weather.idx
      local sep       = bar.tools.separator(symbol, sf, sb, idx)
      bar.weather.sep = sep
      bar.weather.cur = bar.tools.getprog(bar.weather.w_qstr)
    end,

  }


  return bar

end

return weather
