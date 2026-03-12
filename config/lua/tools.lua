local tools = {}
function tools.setup(bar)
  bar["tools"] = {
    getval = function(filename)
      local fp    = assert(io.open(filename, "r"))
      local line  = fp:read("*line")
      fp:close()
      return line
    end,

    getprog = function(program)
      local prg   = assert(io.popen(program, "r"))
      local line  = prg:read("*line")
      prg:close()
      return line
    end,

    separator = function (sep, fg, bg, index)
      local stop = bar.colors.bgstop .. bar.colors.fgstop
      local sepstr = stop .. fg .. bg .. "%{" .. "T" .. index .. "}" .. sep .. stop
      return sepstr
    end,

    file_exists = function(filename)
      local file = io.open(filename, "r")
      local exist = false
      if file then
        file:close()
        exist = true
      end
      return exist

    end,

    ini2lua = function (inif, luaf)
      local section
      local prev
      local indent  = "  "
      local inifile =  inif
      local luafile =  luaf
      local of      = assert(io.open(luafile, "w"))

      if bar.tools.file_exists(inifile) ~= true then
        return false
      end

      for line in io.lines(inifile) do
        if string.find(line, "^%[") then
          section = string.match(line,"%[(.-)%]")
          if prev ~= section and prev ~= nil then
            of:write("}\n")
          end
          of:write(section .. " = {\n")
          prev = section
        else
          of:write(indent .. line .. ",\n")
        end
      end
      of:write("}")
      of:close()
    end,

    mergetables = function(dst, src)
      for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k] or false) == "table" then
          bar.tools.mergetables(dst[k], v)
        else
          dst[k] = v
        end
      end
      return dst
    end,

    sleep = function (int)
     os.execute("sleep " .. tonumber(int))
    end,

  }

  return bar

end

return tools
