-- Template for simple modules.
-- Edit config.ini and add "example" to [settings] -> modules to see it running.
-- Add header [example] to config.ini, place some field names (e.g. fgc1 below the
-- header and play around with the module.
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local  example = {}
function example.setup(bar)
-- Anything availlable for config.ini must be decalared here
  bar["example"] = {
    fgc1    = "",               -- Text color See config.ini for availlable colors.
    fgc2    = "",               -- Text color See config.ini for availlable colors.
    bgc     = "",               -- Background color
    sfg     = "",               -- Separatot forground, color.
    sbg     = "",               -- Separator background, color.
    iv      = 1,                -- Update intervall, required.
    secs    = 0,                -- Internal counter, required.
    show    = "",               -- What the module returns, required.
    sep     = "",               -- Character or glyph used as Separator.
    idx     = bar.symbols.fidx, -- Index symbol font,
    icon    = "",               -- Label or glyph for the modul.
    sp      = bar.fmt.sp,       -- Used for padding.,
    fmt     = "",               -- Alignmen tleft, center, right), required
                                -- Impacts all following modules.
    enabled = false,            -- bar.init() sets this true, if init succeeds                -- 

    -- implement update() as coroutine
    -- bar.show() calls coroutine.resume(bar[<module>][update])
    update = coroutine.create(function()
      local sp    = bar.example.sp
      local c1    = bar.example.fgc1
      local c2    = bar.example.fgc2
      local bc    = bar.example.bgc
      local icon  = bar.example.icon
      local i     = 1
      local enabled = bar.example.enabled

      while enabled do
        -- The actual modul code
        bar.example.show = string.format("%s%s%s%s%s %3d%s", bc, sp, c1, c2, icon, i, sp)
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
      local idx       = bar.example.idx
      local sep       = bar.tools.separator(symbol, sf, sb, idx )
      bar.example.sep = sep
    end,

  }

  return bar

  end

return example
