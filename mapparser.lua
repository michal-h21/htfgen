kpse.set_program_name("luatex")
local M = {}

local fontproperties = require "fontproperties"

local function parse_line(line)
  local line = line or ""
  local clean = line:gsub('%b""',"")
  local fontname, properties, encfile = clean:match("([^%s]+)[%s]+([^%s]+)[%s]+<(.+).enc")
  return fontname, properties, encfile
end
function M.parse_map(filename) 
  local t = {}
  for line in io.lines(filename) do
    local fontname, properties, encoding =  parse_line(line) 
    if fontname then
      -- get fonts with current encoding
      local encfonts = t[encoding] or {}
      encfonts[fontname] = properties
      -- save updated fonts 
      t[encoding] = encfonts 
    end
  end
  return t
end

local encfile = kpse.find_file("gfsdidot","map")
print(encfile)

local t = M.parse_map(encfile)
for encoding, fonts in pairs(t) do
  print("encoding:",encoding)
  for fontname, properties in pairs(fonts) do
    print(fontname, fontproperties.make_css(properties))
  end
end
