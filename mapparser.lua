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

local utfchar = unicode.utf8.char
local t = M.parse_map(encfile)
local checksums = {}
local missing_glyphs = {}
for encoding, fonts in pairs(t) do
  print("encoding:",encoding)
  local s = loadenc.parse(loadenc.load(encoding))
  local min,max
  -- table fof concenating encoding chars
  local t = {}
  for k,v in pairs(s) do
    local g = glyphs:getGlyph(v)
    if g then
      min = math.min(k, min or k)
      max = math.max(k, max or k)
      local ch = tonumber(g,16)
      if not ch then
        print("ploblem with char conversion: ", g)
        ch = 32
      end
      t[#t+1] = utfchar(ch) 
--      print(k,v, glyphs:getGlyph(v))
    elseif v ~= ".notdef" then
      t[#t+1] = " " 
      missing_glyphs[v] = encoding
    end
  end
  -- make checksum of the encoding
  local checksum = md5.sumhexa(table.concat(t))
  checksums[checksum] = (checksums[checksum] or 0) + 1
  print("min-max", min, max, checksum)
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
