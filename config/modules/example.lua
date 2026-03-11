local  testmod = {}
function testmod.setup(bar)
  bar["testmod"] = {
    fgc1    = "%{F#b6c0e9}",
    bgc     = bar.colors.bgc1,
    sfg     = "",
    sbg     = "",
    iv      = 1,
    secs    = 0;
    show    = "",
    sep     = "",
    fmt     = "",
    icon    = "Count:",
    update = coroutine.create(function()
      local c1    = bar.testmod.fgc1
      local bc    = bar.testmod.bgc
      local icon  = bar.testmod.icon
      local i     = 1

      while true do
        bar.testmod.show = string.format("%s%s%s %s ", bc, c1, icon, tostring(i))
        if i >= 10 then
          i = 1
        else
          i = i + 1
        end
        coroutine.yield()
      end
    end),

    init = function ()
      local sf        = bar.testmod.sfg
      local sb        = bar.testmod.sbg
      local symbol    = bar.testmod.sep
      local sep       = bar.tools.seperator(symbol, sf, sb, 3 )
      bar.testmod.sep = sep
    end,

  }

  return bar

  end

return testmod
