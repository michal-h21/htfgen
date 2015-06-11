kpse.set_program_name("luatex")
local M = {}

local fontproperties = require "fontproperties"
local loadenc = require "loadenc"
local glyphs = require "glyphload"

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

local htflib = require "htflib"
local utfchar = unicode.utf8.char
local t = M.parse_map(encfile)
local checksums = {}
local missing_glyphs = {}
for encoding, fonts in pairs(t) do
  print("encoding:",encoding)
  local htf,missing,min,max = htflib.make_htf(encoding)
  for k,v  in ipairs(htf) do
    print(table.concat(v,"\t"))
  end
  for k,v in pairs(missing) do
    missing_glyphs[k] = v
  end
  -- for fontname, properties in pairs(fonts) do
  --   print(fontname, fontproperties.make_css(properties))
  -- end
end
if next(missing_glyphs) ~= nil then
  print "Cannot load unicode values for following glyph names"
  for k, v in pairs(missing_glyphs) do
    print(k,v)
  end
end

for chk, cnt in pairs(checksums) do
  print(chk, cnt)
end
