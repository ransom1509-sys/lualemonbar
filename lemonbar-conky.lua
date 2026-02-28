package.path = package.path .. ";/home/js/.local/share/modules/lua/?.lua"

local lemonbar = require("lemonbar")
local mybar = lemonbar.setup()

-- ************* Conky hooks **************

function conky_init()
  lemonbar.init(mybar)
end

function conky_main()
  print(lemonbar.show(mybar))
end
