local look = {}
function look.setup(bar)
  bar["settings"] = {
    timer   = 1,
    init    = os.getenv("HOME") .. "/.config/lualemonbar/",
    modules_l = "date weather volume Window tmp fan load net mail connect"
  }

  bar["colors"] = {
    fgc1      = "%{F#b6c0e9}",
    fgc2      = "%{F#826bad}",
    fgc3      = "%{F#7aa2f7}",
    fgc4      = "%{F#62baad}",
    fgc5      = "%{F#99c867}",
    fgc6      = "%{F#29bdd7}",
    fgc7      = "%{F#02002f}",
    fgc8      = "%{F#ff9e64}",
    bgc1      = "%{B#1a1b26}",
    bgc2      = "%{B#414447}",
    bgc3      = "%{B#2e3c43}",
    bgc4      = "%{B#6a6f74}",
    sbg1      = "%{B#1a1b26}",
    sbg2      = "%{B#414447}",
    sbg3      = "%{B#2e3c43}",
    sbg4      = "%{B#6a6f74}",
    sfg1      = "%{F#1a1b26}",
    sfg2      = "%{F#414447}",
    sfg3      = "%{F#2e3c43}",
    sfg4      = "%{F#6a6f74}",
    unread    = "%{F#da5f8b}",
    connected = "%{F#99c867}",
    inv       = "%{F#00b6c0e5}",
    bgstop    = "%{B-}",
    fgstop    = "%{F-}",
  }

  bar["seperators"] = {
    tal   = "",
    tar   = "",
    pos   = "right",
  }

  bar["symbols"] = {
    temp = "",
    fan  = "",
    cpu  = "", --> U+EB03 => Nerd Fonts
    -- cpu  = "",
    mail = "", -- U+E0E1 => typicons.ttf
    net  = "", -- U+E059 => typicons.ttf
    con  = "",
    wthr = "", -- U+E13B => typicons.ttf
    vol  = "",
  }

  bar["fmt"] = {
    fl = "%{l}",
    fr = "%{r}",
    fc = "%{c}",
    ml = "%{O20}",
    mr = "%{O20}",
    sp = "  ",
  }


  return bar

end

return look
