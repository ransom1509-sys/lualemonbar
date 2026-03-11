-- Template for simple modules.
-- Edit config.ini and add "example" to [settings] -> modules to see it running.
-- Add header [example] to config.ini, place some field names (e.g. fgc1 below the
-- header and play around with the module.
local  example = {}
function example.setup(bar)
-- Anything availlable for config.ini must be decalared here
  bar["example"] = {
    fgc1    = "%{F#b6c0e9}",    -- Text color See config.ini for availlable colors.
    bgc     = bar.colors.bgc1,  -- Background colo. 
    sfg     = "",               -- Separatot forground, color.
    sbg     = "",               -- Separator background, color.
    iv      = 1,                -- Update intervall, required.
    secs    = 0;                -- Internal counter, required.
    show    = "",               -- What the module returns, required.
    sep     = "",               -- Character or glyph used as Separator.
    icon    = "Count:",         -- Label or glyph for the modul.
    fmt     = "",               -- Alignmen tleft, center, right), required
                                -- Impacts all following modules.

    -- implement update() as coroutine
    -- bar.show() calls coroutine.resume(bar[<module>][update])
    update = coroutine.create(function()
      local c1    = bar.example.fgc1
      local bc    = bar.example.bgc
      local icon  = bar.example.icon
      local i     = 1

      while true do
        -- The actual modul code
        bar.example.show = string.format("%s%s%s %s ", bc, c1, icon, tostring(i))
        if i >= 10 then
          i = 1
        else
          i = i + 1
        end
        coroutine.yield()
      end
    end),

    -- Any required initialisatiom
    -- Can be empty, but must be present
    init = function ()
      local sf        = bar.example.sfg
      local sb        = bar.example.sbg
      local symbol    = bar.example.sep
      local sep       = bar.tools.seperator(symbol, sf, sb, 3 )
      bar.example.sep = sep
    end,

  }

  return bar

  end

return example
