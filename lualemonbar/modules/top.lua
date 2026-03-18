-- Top cpu / mem modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local  top = {}
function top.setup(bar)
-- Anything availlable for config.ini must be decalared here
  bar["top"] = {
    fgc1    = bar.colors.fgc1,  -- Text color See config.ini for availlable colors.
    bgc     = bar.colors.bgc1,  -- Background colo. 
    sfg     = "",               -- Separatot forground, color.
    sbg     = "",               -- Separator background, color.
    iv      = 1,                -- Update intervall, required.
    secs    = 0;                -- Internal counter, required.
    show    = "",               -- What the module returns, required.
    sep     = "",               -- Character or glyph used as Separator.
    idx     = bar.symbols.fidx, -- Index symbol font
    icon    = "Top:",           -- Label or glyph for the modul.
    sp      = "",               -- Space for padding
    fmt     = "",               -- Alignmen tleft, center, right), required
                                -- Impacts all following modules.
    tc_str  = "ps -eo comm,%mem,%cpu --sort=%cpu | tail -n 1 | cut -d ' ' -f 1",
    tm_str  = "ps -eo comm,%mem,%cpu --sort=%mem | tail -n 1 | cut -d ' ' -f 1",
    enabled = false,

    -- implement update() as coroutine
    -- bar.show() calls coroutine.resume(bar[<module>][update])
    update = coroutine.create(function()
      local topc, topm
      local c1       = bar.top.fgc1
      local bc       = bar.top.bgc
      local icon     = bar.top.icon
      local sp       = bar.top.sp
      local enabled  = bar.top.enabled

      while enabled do
        -- The actual modul code
        topc  = bar.tools.getprog(bar.top.tc_str)
        topm  = bar.tools.getprog(bar.top.tm_str)
        bar.top.show = string.format("%s%s%s%s %s %s%s",
          bc, sp, c1, icon, topc, topm, sp)
        coroutine.yield()
      end
    end),

    -- Any required initialisatiom
    -- Can be empty, but must be present
    init = function ()
      local sf        = bar.top.sfg
      local sb        = bar.top.sbg
      local symbol    = bar.top.sep
      local idx       = bar.top.idx
      local sep       = bar.tools.separator(symbol, sf, sb, idx)
      bar.top.sep = sep
      bar.tools.getprog(bar.top.tc_str)
      bar.tools.getprog(bar.top.tm_str)
    end,

  }

  return bar

  end

return top
