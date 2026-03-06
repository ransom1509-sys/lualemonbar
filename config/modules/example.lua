local bar = {}

bar["testmod"] = {
  fgc1    = "%{F#b6c0e9}",
  iv      = 1,
  secs    = 0;
  show    = "",
  update = coroutine.create(function()
    local c1 = bar.testmod.fgc1
    for i = 1, 10 do
      bar.testmod.show = string.format("%sUppdate %s  ", c1, tostring(i))
      coroutine.yield()
    end
  end),

  init = function ()
  end,

}

return bar
