local mail = {}
function mail.setup(bar)
  bar["mail"] = {
    fgc1    = bar.colors.fgc1,
    fgc2    = bar.colors.unread,
    bgc     = bar.colors.bgc1,
    sfg     = bar.colors.sfg1,
    sbg     = bar.colors.sbg2,
    sep     = bar.seperators.tal,
    icon    = bar.symbols.mail,
    nm_qstr = "claws-mail --status | cut -d ' ' -f 2",
    secs    = 0,
    iv      = 2,
    show    = "",

    update = coroutine.create(function ()
    local c1    = bar.mail.fgc1
    local c2    = bar.mail.fgc2
    local mc    = bar.mail.fgc1
    local bc    = bar.mail.bgc
    local mail  = bar.mail.icon
    local sep   = bar.tools.seperator(bar.mail.sep, bar.mail.sfg, bar.mail.sbg, 3)
    while true do
    --   New mails?
    bar.mail.mails = tonumber(bar.tools.getprog(bar.mail.nm_qstr))
    if bar.mail.mails ~= nil and bar.mail.mails > 0 then
     mc = c2
    else
     mc = c1
    end

    bar.mail.show = string.format(" %s%s%s%s ", sep, bc, mc, mail)
    coroutine.yield()
    end
    end),

    init = function ()
    bar.mail.mails = tonumber(bar.tools.getprog(bar.mail.nm_qstr))
    end,

    }

  return bar

end

return mail
