# Lualemonbar

Lualemonbar - A lightweight lua wrapper for lemonbar.
Lualemonbar is a wrapper for lemonbar that provides a configuration interface for lemonbar or lemonbar-xft, thereby keeping lemonbar as light as possible.
Lualemonbar allows the configuration of almost every lemonbar feature through a `config.ini` file. Lualemonbar also allows the configuration of all used modules, if there attributes are exposed to `config.ini`.  

![configure lemonbar with config.ini](</screenshots/lualemonbar - config.ini file.png>)

## Features

With lualemonbar you can

- set the lemonbar start command
- define colors
- define glyphs for icons (requires lemonbar-xft and a symbol font)
- set the modules diisplay order
- set what modules to load
- crreate and add your qwn modules using a module template
- set individual update intervals
- set update intervals < 1s (requires LuaSocket)
- set lemonbar formating options (left center right)
- set module padding
- set a spacer of variable length
- use different symbol fonts for separators
- define separators (global or for individual modules)
- use themes or create your own

Except for writing modules, all is done through one `config.ini` file.

Lualemonbar is lightweight.
Lemonbar running through lualemonbar with an update interval of 0.5 seconds, has a cpu usage of 0.2% - 0.5% and uses 9 MB memory. 


## Motivation

I use lemonbar exclusively in my WMs (mostly fluxbox) but the scripts providing the data became larger and larger. 
Lemobar's performance suffered and making changes to settings became increasingly difficult. So I decided to rewrite my script with thee goals in my mind: Make the script modular, make each bar module a self contained, loadable unit and make it easy to configure. As time went by, what started as QoL features for myself now has become a full blown application, hopefully being useful for others as well. 

## Installation

Requirements

Any of the soft requirements can be replaced by alternatives of your choice. Just edit the coresponding entry in the `config.ini` file.

Hard
- Lua 5.4 (older versions may work too).
- Lemonbar or lemonbar-xft.

Soft
- [LuaSocket](https://github.com/lunarmodules/luasocket) for update intervals < 1s.
- xdotool for the window module.
- nvidia-smi or amd-smi for the tmp module.
- Pulseaudio for volume control.
- ansiweather for current weather conditions.
- nmcli for connection status
- [imap-cli](https://github.com/Gentux/imap-cli) or a decent email prog like [claws-mail](https://www.claws-mail.org/) for mail.  
  I use claws-mail, the only email program I know, that supports querying the
  number of unread messages across all servers as command line argument.

Lualemonbar probes at startup for LuaSocket and falls back to the internal sleep function, if neccessary.


Install lualemonbar

Clone the repository
```bash
  git clone https://githup.com/ransom1509-sys/lualemonbar
```
or download the compressed archive and extract

Create a lualemonbar directory in $HOME/.config
```bash
  mkdir <your_account>/.config/lualemonbar
```
Go to location of the downloaded repository.
```bash
  cd /path_to_lualemonbar_src
```
Copy the contents of the config folder to $HOME/.config/lualemonbar/
```bash
  cp -R config/*  $HOME/.config/lualemonbar/
```
Make lualemonbar executable
```bash
  chmod +x lualemonbar
```
and copy it to a locatioon in your path.

Run lualemonbar.

Most likely you will see error messages displayed in the bar, but if the
installation was correct, date, load and top should work. If they do not, or 
nothing is displayed, start lualemonbar from a terminal and look for error messages.

Open `$HOME/.config/lualemonbar/config.ini`.

Read the [Configuration](#configuration) section in this document and adapt the module
settings to your system.

## Configuration

### Format of `config.ini`

The `config.ini` file has the standard .ini file format, looking like this
```dosini
[section]
value_1 = "foo"
value_2 = "bar"
```
In lualemonbar's `config.ini` three types of values are supported: strings, numbers and references
```dosini
[section] 
string = "this is a string"
number = 6
my_string = section.string
```
Sections and var names do not have quotes or white space in their names.
Strings are always quoted and may contain spaces.
References are not quoted.

### The .ini file

Most of `config.ini` is self-explanatory.
```
[settings]   - General setting
timer        - Sets the lowest possible update interval. This does NOT change the update
               interval. Setting timer lower than 1 requires LuaSockets. 
modules      - The modules to load.
cmd          - The lemonbar command.

[colors]     - Color definitions and lemonbar definitions for starting and stopping colors.
               See man lemonbar. 

[symbols]    - Definition of symbols used for icons. Must be supported by the installed
               fonts.
fidx         - Font index. Number from 1 to 5. The number of the font for the separator
               symbols, e.g. fidx = 3 => third font loaded with the lemonbar command.
               This should be under the separators section, but slipped in here.

[separators] - Charactrers used as separators. Can be unicode glyphs, but then the installation
               of a symbol font is required. symbols.fidx specifies the symbol font to use.

[fmt]        - Formatters. Note that lemonbar formatters always use the full bar length for
               calculation.
fl           - Anything that follows is aligned left until a new formatter is met.
fr           - Like fl but to the right.
fc           - Like fl and fr but centered.
sp           - A string of spaces. Used for padding. Not a lemonbar formatter. Padding set here
               applies to all bar modules, unless they have their own sp value set. 

[spacer]     - A special module. Creates space.
width        - Width in spaces.
sep          - Separator to use.

[module]     - Name of a module to configure.
bgc1         - Background colors.
fgc1         = Text color.
fgc2         - Usually the icon or label color.
sfg          - Separator forground color.
sbg          - Separator background color.
icon         - Symbol used as icon or a text label.
sep          - The sparator to use.
fmt          - A lemonbar formater (leftt, center, right).
iv           - The update intervall. Can not be < settings.timer 
```
### A sample `config.ini`
```dosini
[settings]
timer =  0.5
modules = "date weather volume spacer window tmp fan load net mail"
cmd = "lemonbar -g 1920x16+0+0 -p -f \'Cousine for Powerline:pixelsize=14\' -f Typicons:pixelsize=16 -f \'Symbols Nerd Font Mono:pixelsize=16\' -B#ff1a1b26 | /bin/sh"
[colors]>
bgc1 =  "%{B#1a1b26}"
bgc2 =  "%{B#414447}"
fgc1 =  "%{F#b6c0e9}"
fgc2 =  "%{F#826bad}"
sbg1 =  "%{B#1a1b26}"
sbg2 =  "%{B#414447}"
sfg1 =  "%{F#1a1b26}"
sfg2 =  "%{F#414447}"
bgstop =  "%{B-}"
fgstop =  "%{F-}"
connected =  "%{F#99c867}"
unconnect = "%{F#444b6a}"
unread =  "%{F#da5f8b}"
[symbols]
fan =  ""
fidx = 3
[separators]
tar =  ""
tal =  ""
[fmt]
fl = "%{l}"
fr = "%{r}"
fc = "%{c}"
ml = "%{O20}"
mr = "%{O20}"
sp  = " "
[spacer]
width = 4
sep = ""
[fan]
bgc =  colors.bgc1
fgc1 =  colors.fgc1
fgc2 =  "%{F#7aa2f7}"
sbg =  colors.sbg2
sfg =  colors.sfg1
icon = symbols.fan
iv =  10
cf_qstr =  "/sys/class/hwmon/hwmon1/fan1_input"
sf_qstr =  "/sys/class/hwmon/hwmon1/fan2_input"
sep =  separators.tar
```
### Themes

Themes are stylish `config.ini` files. Five themes are currently available in lualemonbar/themes.

- `clean.ini` - Elegant b/w dark theme
  
  ![clean theme](</screenshots/lualemonbar - clean.png>)

- `default.ini` - The default config.ini

  ![default theme](</screenshots/lualemonbar- default - no icons.png>)
  
- `lualine.ini` - Inspired by NeoVim Lualine status bar

  ![lualine theme](</screenshots/lualemonbar- lualine.png>)
  
- `simple.ini` - No icons or symblos. Works without symbol fonts

  ![simple theme](</screenshots/lualemonbar-  simple clean.png>)
  
- `tokyonight.ini` - like default.ini, but with icons and left-center-right layout

   ![tokyonight theme](</screenshots/lualemonbar- default - formats and icon fonts.png>)

To use a theme just copy it to `config.ini`, e.g.
```bash
  cd $HOME/.config/lualemonbar/
  cp themes/simple.ini config.ini
```  
## Bar modules

Lualemonbar currently provides 12 bar modules (or plugins, if you prefer) and there are more to come.

Available modules:

Cpu:
- shows cpu usage in percent
- show average of all cpus combined
- usage is calculated from /proc/stat
- only the data source (/proc/stat) can be changed

Date: 
- shows date and time
- has a button (e.g. for calling a calendar app) 
- date and time format can be changed in config.ini
- button action can be changed in config.ini

Example
- module template
- shows a simple counter
- can be used to create your own Modules

Fan:
- shows current speed of cpu fan and system fan
- calls used can be adated to your system in config.ini

Mail:
- innforms about new Mail
- the program used for new mail notification can be set in config.ini

Net:
- Shows in/out trafic in KiB/s and connectioon status for wired connections
- the net interface and data source can be changed in config.ini

Spacer:
- creates a space of variable length
- useful for module placing and left side separators (see Configuration)

Tmp:
- shows current cpu/system/gpu temperature
- calls used can be adapted to your system in config.ini

Top
- displays the top cpu/mem process
- calls can be configured in config.ini

Volume:
- shows volume in percent
- has left/middle/right click buttons for volume control (pactl and pavucontrol)
- commands can be changes in config.ini
  
Weather:
- uses ansiweather for actual weather
- has a button (e.g. to call wego or wttr.in)
- weather app and button command can be changed in config.ini

Window:
- displays the name of the active window (requires xdotool)  
- xdotool prorbably will be replaced by a native solution
- command can be changed in config.ini
- length of window title display can be set in config.ini 

The appearance of each module can be configured in config.ini.

I can not provide modules for WiFi or battery status, my portables are all Android devices, but you are welcome to contribute any wireless, battery or other missing modules (see [Contributing](#contributing](#contributing))).

## How does it work

You do not invoke lualmonbar the usual way, like `"myscript | lemonbar -p"`. Lualemonbar is a stanalone executable, using the `setup()`, `init()`, `cmd()` and `show()` functions provided by lemonbar.lua. After installation and some setup steps (see [Installation](#installation)), put it in your path and run "lualemonbar".

The heavy lifting is done by `lemonbar.init()`: 

- loading additional required lua modules
- adapting `package.path`
- checking for `congfig.ini`
- generating `config.lua` from `config.ini`
- merging `config.lua` with the defaults
- building a bar module table 
- loading the wanted bar modules
- merge configuration for loaded bar modules
- testing the bar modules `init()` functions and enable on succes

Bar modules are loaded from lualemonbar/modules with `require()`
and the module's `setup()` function.

All bar Modules have an `update()` function, implemented as coroutine:
```lua
      local enabled = bar.mymodule.enabledd
      update = coroutine.create(function()

      while enabled do
        -- The actual modul code
        code_to_get_some_data_to_display
        bar.mymodule.show = string.format(<data>)
        coroutine.yield()
      end
    end),
```
The bar module's `enabled` flag is set by `lemonbar.init()`
```lua
      if pcall(bar[mymodule].init) then
        bar[mymodule].enabled = true
      else
        bar[mymodule].show = "mymodule" .. ": error"
      end
```
The `pcall()` test only works when `mymodule.init()` contains

  code_to_get_some_data_to_display

When not, `enabled` is set to `true`, regardless, of any errors caused
by the code in `update()` (e.g. program does not exist).
Unless something else went wrong in `init()`, that is.



The data to display in the bar is piped to lemonbar by `lemonbar.show()`
```lua
      local pipe_out = assert(io.popen(cmd, "w"))
      
      for _, val in pairs(module_table) do
        if bar[val].iv - bar[val].secs <= 0 then
          coroutine.resume(bar[val].update)
          bar[val].secs = 0
        else
          bar[val].secs = bar[val].secs + bar.settings.timer
        end
        show = show .. bar[val].fmt .. bar[val].show .. bar[val].sep
      end
      pipe_out:write(show .. "\n")
      pipe_out:flush()
      show = ""
```
where `cmd` is the actual lemonbar start command retrieved from `config.ini` (e.g. `"lemonbar -p"`).

## Writing your own modules

If you want to write your own bar modules, I recommend that you use example.lua as template. With the template you can create simple modules, even if you don't know lua.

Here are some tips:

Copy `example.lua` to `mymodule_name.lua`.
In `mymodule_name.lua` change all occurences of `example` to `mymodule_name`.
Create a new field, e.g `cmd_str` in `bar["mymodule_name"]` and place it before `update`.

```lua
    bar["mymodule_name"] = {
    ..
    cmd_str = "",  -- leave empty, you set it in config.ini
    update = ...
```
Lualemonbar provides two helper functions, `bar.tools.getval(filename)` and `bar.tools.getprog(program)`.  
Function `bar.tools.getval()` is a wrapper for `io.read()` and returns the first line of a file.  
Function `bar.tools.getprog()` is a wrapper for `io.popen()` and returns one line of program output. 

Example
```lua
    bar.tools.getval("/proc/stat") --> first line of /proc/stat
    bar.tools.getprog("tail -n 1 /proc/stat") --> last line of /proc/stat
    bar.tools,getval("/sys/class/net/eth0/statistics/tx_bytes") --> all transmitted bytes
```
The `while` loop in `update()` retrieves the actual data. Use `getval(cmd_str)` or `getprog(cmd_str)` to get the required data.  
Do not put anything that needs to be updated in front of the `while` loop, `update()` is  only called once on `lemonbar.init()`.

Put anything you want to configure into `config.ini`:
```dosini
    [mymodul_name]
    cmd_str = "my command"
    fgc1 = ""
    fgc2 = ""
    sp = ""
    sep = ""
    ...
```    
If you want to contribute yor module here, put your data rerieval code in your module's `init()` function, so it can be tested by `lemonbar.init()`.
```lua
    init = function ()
        ...
        test = bar.tools.getprog(cmd_str)
        ...
    end

```    
On errors, like missing files or programs, `lemonbar.init()` will safely disable the module, without crashing the bar.

## FAQ

Why does changing the timer value not change the update frequency of my modules?  
The timer calibrates the main loop, setting the lowest update interwal possible.
To change a module's update frequency, edit the modules iv value in config.ini.

How can I enclose a module / several modules in matching separators, e.g. right and
left arrow?  
Separators are always on the right side of the module, but you can put a spacer in front
of the module and give it a separator. See the [lualine theme](/config/themes/lualine.ini) for an example.

## Contributing

- PRs are welcome.
- Use examples.lua, if you want to contribute a cool, new module.
- Found a bug? Create an issue.

## Contribute
Like this project?<br>
Leave a star, if you think this project is cool.

## License
MIT

## Author
Jörg Stadermann
