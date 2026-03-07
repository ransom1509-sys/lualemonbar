local window = {}
function window.setup(bar)
  bar["window"] = {
    fgc1    = bar.colors.fgc8,
    w_str   = "xdotool getactivewindow getwindowname",
    show    = "",
    secs    = 0,
    iv      = 0.5,

    update = coroutine.create(function()
      local c1 = bar.window.fgc1
      local wname
      while true do
        wname = bar.tools.getprog(bar.window.w_str)
        if wname ~= nil then
          bar.window.show = string.format("%s%s", c1, wname)
        else
          bar.window.show = ''
        end
        coroutine.yield()
      end
    end),

    init = function ()
    end
  }

  return bar

end

return window
