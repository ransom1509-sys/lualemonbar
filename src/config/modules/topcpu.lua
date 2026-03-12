-- Template for simple modules.
-- Edit config.ini and add "topcpu" to [settings] -> modules to see it running.
-- Add header [topcpu] to config.ini, place some field names (e.g. fgc1 below the
-- header and play around with the module.
local  topcpu = {}
function topcpu.setup(bar)
-- Anything availlable for config.ini must be decalared here
  bar["topcpu"] = {
    fgc1    = "%{F#b6c0e9}",    -- Text color See config.ini for availlable colors.
    bgc     = bar.colors.bgc1,  -- Background colo. 
    sfg     = "",               -- Separatot forground, color.
    sbg     = "",               -- Separator background, color.
    iv      = 1,                -- Update intervall, required.
    secs    = 0;                -- Internal counter, required.
    show    = "",               -- What the module returns, required.
    sep     = "",               -- Character or glyph used as Separator.
    icon    = "Top CPU:",         -- Label or glyph for the modul.
    fmt     = "",               -- Alignmen tleft, center, right), required
                                -- Impacts all following modules.
    tp_str  = "ps -eo comm,%mem,%cpu --sort=%cpu | tail -n 1 | cut -d ' ' -f 1",

    -- implement update() as coroutine
    -- bar.show() calls coroutine.resume(bar[<module>][update])
    update = coroutine.create(function()
      local c1    = bar.topcpu.fgc1
      local bc    = bar.topcpu.bgc
      local icon  = bar.topcpu.icon
      local cmd   = bar.topcpu.tp_str
      local top

      while true do
        -- The actual modul code
        top  = bar.tools.getprog(cmd)
        bar.topcpu.show = string.format("%s%s%s %s ", bc, c1, icon, top)
        coroutine.yield()
      end
    end),

    -- Any required initialisatiom
    -- Can be empty, but must be present
    init = function ()
      local sf        = bar.topcpu.sfg
      local sb        = bar.topcpu.sbg
      local symbol    = bar.topcpu.sep
      local sep       = bar.tools.seperator(symbol, sf, sb, 3 )
      bar.topcpu.sep = sep
    end,

  }

  return bar

  end

return topcpu
