#!/usr/bin/lua
package.path = package.path .. ";/home/js/.local/share/modules/lua/?.lua"

local lemonbar = require("lemonbar")
local mybar    = lemonbar.setup()
local posix = require("posix")
-- local socket = require("socket")
local sleep = posix.sleep
local n     = 1

-- +++++++++++ Stand-alone ++++++++++++++++

lemonbar.init(mybar)
while true do
  print(lemonbar.show(mybar))
  sleep(n)
end
