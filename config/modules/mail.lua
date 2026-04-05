-- Mail notification modul for lualemonbar
-- (c) 2026 - Jörg stadermann <mail@jstadermann.de>
local mail = {}
function mail.setup(bar)
  bar["mail"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.unread,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg2,
    sep     = "",
    idx     = bar.symbols.fidx,
    sp      = bar.fmt.sp,
    fmt     = "",
    icon    = bar.symbols.mail,
    new     = bar.symbols.mail_new,
    mails   = 0,
    nm_qstr = "",
    secs    = 0,
    iv      = 2,
    show    = "",
    enabled = false,

    update = coroutine.create(function ()
    local c1    = bar.mail.fgc1
    local c2    = bar.mail.fgc2
    local mc    = bar.mail.fgc1
    local bc    = bar.mail.bgc
    local icon  = bar.mail.icon
    local sp    = bar.mail.sp
    local enabled = bar.mail.enabled
    local getprog = bar.tools.getprog

    while enabled do
    --   New mails?
      bar.mail.mails = tonumber(getprog(bar.mail.nm_qstr))
      if bar.mail.mails ~= nil and bar.mail.mails > 0 then
       mc = c2
       icon = bar.mail.new
      else
       mc = c1
       icon = bar.mail.icon
      end
      bar.mail.show = string.format("%s%s%s%s%s", bc, sp, mc, icon, sp)
      coroutine.yield()
    end
  end),

    init = function ()
      local idx     = bar.mail.idx
      local sep = bar.tools.separator(bar.mail.sep, bar.mail.sfg, bar.mail.sbg, idx)
      local getprog = bar.tools.getprog
      bar.mail.mails = tonumber(getprog(bar.mail.nm_qstr))
      bar.mail.sep = sep
    end,
  }

  return bar

end

return mail
