-- Volume control modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local volume = {}
function volume.setup(bar)
  bar["volume"] = {
    fgc1      = bar.colors.fgc1,
    fgc2      = bar.colors.fgc2,
    bgc       = bar.colors.bgc1,
    sfg       = bar.colors.sfg1,
    sbg       = bar.colors.sbg3,
    v_get_str = "",
    v_set_str = "",
    action    = "",
    cur_vol   = 0,
    prev_vol  = 0,
    vol_up    = 0,
    vol_down  = 0,
    max_vol   = 65536,
    vol_perc  = 0,
    step      = 1310,
    icon      = bar.symbols.vol,
    sep       = bar.separators.tar,
    idx       = bar.symbols.fidx,
    fmt       = "",
    sp        = bar.fmt.sp,
    secs      = 0,
    iv        = 2,
    show      = "",
    enabled   = false,

    update = coroutine.create(function ()
      local symbol  = bar.volume.icon
      local c1      = bar.volume.fgc1
      local c2      = bar.volume.fgc2
      local bc      = bar.volume.bgc
      local sp      = bar.volume.sp
      local percent = bar.volume.vol_perc
      local action  = bar.volume.action
      local up      = tostring(bar.volume.vol_up)
      local down    = tostring(bar.volume.vol_down)
      local inc     = bar.volume.v_set_str .. up
      local dec     = bar.volume.v_set_str .. down
      local enabled = bar.volume.enabled
      local getprog = bar.tools.getprog

      while enabled do
        bar.volume.cur_vol  = getprog(bar.volume.v_get_str)

        -- if bar.volume.cur_vol ~= bar.volume.prev_vol then
        bar.volume.vol_perc = 100 * bar.volume.cur_vol // bar.volume.max_vol
        percent = bar.volume.vol_perc
        -- bar.volume.prev_vol = bar.volume.cur_vol

        if bar.volume.cur_vol + bar.volume.step <= bar.volume.max_vol then
          bar.volume.vol_up   = bar.volume.cur_vol + bar.volume.step
        end

        if bar.volume.cur_vol - bar.volume.step >= 0 then
          bar.volume.vol_down = bar.volume.cur_vol - bar.volume.step
        end
        -- end
        up   = tostring(bar.volume.vol_up)
        down = tostring(bar.volume.vol_down)
        inc  = bar.volume.v_set_str .. up
        dec  = bar.volume.v_set_str .. down

        bar.volume.show = string.format(
          "%s%s%s%s%s %%{A1:%s:}%%{A2:%s:}%%{A3:%s:}%s%%%%{A}%%{A}%%{A}%s",
          bc, sp, c2, symbol, c1, dec, action, inc, percent, sp)
        coroutine.yield()
      end
    end),

    init = function()
      local sf       = bar.volume.sfg
      local sb       = bar.volume.sbg
      local symbol   = bar.volume.sep
      local idx      = bar.volume.idx
      local sep      = bar.tools.separator(symbol, sf, sb, idx)
      local getprog = bar.tools.getprog
      bar.volume.sep = sep
      bar.volume.cur_vol  = getprog(bar.volume.v_get_str)
      bar.volume.prev_vol = bar.volume.cur_vol
      bar.volume.vol_perc = 100 * bar.volume.cur_vol // bar.volume.max_vol

      if bar.volume.cur_vol + bar.volume.step <= bar.volume.max_vol then
        bar.volume.vol_up   = bar.volume.cur_vol + bar.volume.step
      end

      if bar.volume.cur_vol - bar.volume.step >= 0 then
        bar.volume.vol_down = bar.volume.cur_vol - bar.volume.step
      end

    end,

  }


  return bar

end

return volume
