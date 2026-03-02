#!/usr/bin/lua
package.path = package.path .. ";/home/js/.local/share/modules/lua/?.lua"

local lemonbar = require("lemonbar")
local mybar    = lemonbar.setup()
local posix = require("posix")
-- local socket = require("socket")
local sleep = posix.sleep
local n     = 1
local cmd  = "lemonbar -g 1056+0+0 -p -u 2 -f \'Cousine for Powerline:pixelsize=14\' -f \'Typicons:pixelsiz=14\' -f \'Symbols Nerd Font Mono:pixelsize=14\' -f  \'Cousine for Powerline:style=Bold:pixelsize=14\' -B#ff1a1b26 | sh"

-- cmd = "lemonbar -p"
local pipe_out = assert(io.popen(cmd, "w"))
local text

lemonbar.init(mybar)

while true do
  text = lemonbar.show(mybar) .. "\n"
  pipe_out:write(text)
  pipe_out:flush()
  sleep(n)
end
