local tools = {}
function tools.setup(bar)
  bar["tools"] = {
    getval = function(filename)
      local line
      local fp = io.open(filename, "r")
      if fp then
        line = fp:read("*line")
        fp:close()
        return line
      end
      error()
    end,

    getprog = function(program)
      local line
      local prg = io.popen(program, "r")
      if prg then
        line = prg:read("*line")
        prg:close()
        return line
      end
      error()
    end,

    separator = function (sep, fg, bg, index)
      sep = sep or ""
      local sepstr
      local stop = bar.colors.bgstop .. bar.colors.fgstop
      sepstr = stop .. fg .. bg .. "%{" .. "T" .. index .. "}" .. sep .. stop
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

    makecmd = function ()
      local tbl = {}
      local ot  = {}
      local idx = {}
      local cmdstr = "lemonbar -p"
      local optstr = ""
      local shell  = ""

      local options = {
        a = function (val) return " - a " .. val end,
        b = function (val) if val == "true" then return " -b" else return "" end end,
        d = function (val) if val == "true" then return " -d" else return "" end end,
        g = function (val) return " -g " .. val end,
        n = function (val) return " -n " .. val end,
        o = function (val) return " -o " .. val end,
        s = function (val) shell =  " | " .. val return "" end,
        u = function (val) return " -u " .. val end,
        B = function (val) return " -B" .. val end,
        F = function (val) return " -F" .. val end,
        U = function (val) return " -U" .. val end,
        f = function (val) return " -f " .. "'" .. val .. "'" end,
      }

      ot = options
      -- create font slots.
      ot.f_1, ot.f_2, ot.f_3, ot.f_4, ot.f_5 = ot.f, ot.f, ot.f, ot.f, ot.f

      tbl = bar.start
      for k in pairs(ot) do table.insert(idx, k) end
      -- make sure fonts are always in the same order
      table.sort(idx)
      for _, k in ipairs(idx) do
        if tbl[k] and tbl[k] ~= "" then
          optstr = ot[k](tbl[k])
          cmdstr = cmdstr .. optstr
        end
      end
      print(cmdstr)
      return cmdstr .. shell
    end,
  }

  return bar

end

return tools
