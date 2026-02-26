#!/usr/bin/lua
package.path = package.path .. ";/home/js/.local/share/modules/lua/?.lua"

local mybar = require("lemonbar")
local posix = require("posix")
local sleep = posix.sleep
local n     = 1

-- ************ Overwriting defaulta ************
mybar.colors.bgc5 = "%{B#1a1b26}"
mybar.colors.sbg5 = "%{B#1a1b26}"
mybar.colors.sfg5 = "%{F#1a1b26}"

-- mybar.date.fgc1   = mybar.colors.fgc1
mybar.date.bgc    = "%{B#1a1b26}"
mybar.date.fgc1   = "%{F#7aa5f5}"
mybar.date.sfg    = "%{F#1a1b26}"
mybar.date.sbg    = mybar.colors.sbg5
mybar.tmp.bgc     = mybar.colors.bgc5
mybar.tmp.sfg     = mybar.colors.sfg5
mybar.tmp.sbg     = mybar.colors.sbg5
mybar.weather.sbg = mybar.colors.sbg1
mybar.weather.sfg = mybar.colors.sfg1
mybar.weather.bgc = mybar.colors.bgc1
mybar.net.bgc     = mybar.colors.bgc5
mybar.net.sfg     = mybar.colors.sfg5
mybar.net.sbg     = mybar.colors.bgc5
mybar.fan.bgc     = mybar.colors.bgc5
mybar.fan.sfg     = mybar.colors.sfg5
mybar.fan.sbg     = mybar.colors.sbg5
mybar.load.bgc    = mybar.colors.bgc1
mybar.load.sfg    = mybar.colors.sfg1
mybar.load.sbg    = mybar.colors.sbg1
mybar.load.iv     = 2
mybar.seperators.tal = ""
mybar.seperators.tar = ""

-- +++++++++++ Stand-alone ++++++++++++++++

mybar.init()
while true do
  print(mybar.show())
  sleep(n)
end
