local load = {}
function load.setup(bar)
  bar["load"] = {
    fgc1          = bar.colors.fgc1,
    fgc2          = bar.colors.fgc6,
    bgc           = bar.colors.bgc2,
    sfg           = bar.colors.sfg2,
    sbg           = bar.colors.sbg1,
    sep           = bar.seperators.tar,
    icon          = bar.symbols.cpu,
    st_qstr       = "/proc/stat",
    cpu_last      = 0,
    cpu_last_sum  = 0,
    cpu_load      = 0,
    iv            = 5,
    secs          = 0,
    show          = "",

    update = coroutine.create(function ()
      local cpu_now   = {}
      local cpu_sum   = 0
      local cpu_delta = 0
      local cpu_idle  = 0
      local cpu_used  = 0
      local cpu
      local c1      = bar.load.fgc1
      local c2      = bar.load.fgc2
      local bc      = bar.load.bgc
      local icon    = bar.load.icon
      local sep     = bar.load.sep
      local cpu_usage = 0

      while true do
        -- get cpu stats
        cpu_now = {}
        cpu_sum   = 0
        cpu_delta = 0
        cpu_idle  = 0
        cpu_used  = 0

        cpu = bar.tools.getval(bar.load.st_qstr)
        -- Convert string to table
        for w in string.gmatch(cpu, "[^%s]+") do
          table.insert(cpu_now, w)
        end
        -- Sum up all fields, skip first with "cpu" in it
        for key, val in pairs(cpu_now) do
          if key > 1 then
            cpu_sum = cpu_sum + val
          end
        end
        -- Calculate cpu usage
        cpu_delta   = cpu_sum - bar.load.cpu_last_sum
        cpu_idle    = cpu_now[5] - bar.load.cpu_last
        cpu_used    = cpu_delta - cpu_idle
        cpu_usage   = 100 * cpu_used // cpu_delta
        -- Store values for compare, re-initialize vars for next run
        bar.load.cpu_last     = cpu_now[5]
        bar.load.cpu_last_sum = cpu_sum
        -- cpu_now               = {}
        -- cpu_sum               = 0

        bar.load.cpu_load = cpu_usage

        bar.load.show = string.format("%s%s%s %s %s%3d%% ", sep, bc, c2, icon, c1, bar.load.cpu_load)
      coroutine.yield()
      end
    end),


    init = function ()
      local sf      = bar.load.sfg
      local sb      = bar.load.sbg
      local symbol  = bar.seperators.tar
      local sep     = bar.tools.seperator(symbol, sf, sb, 3 )
      bar.load.sep  = sep
    end
  }


  return bar

end

return load
