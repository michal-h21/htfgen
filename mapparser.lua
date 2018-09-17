kpse.set_program_name("luatex")
local M = {}

local fontproperties = require "fontproperties"
local loadenc = require "loadenc"
local glyphs = require "glyphload"
local template = require "litfonts-template"

local function parse_line(line)
  local line = line or ""
  local clean = line:gsub('%b""',"")
  local fontname, properties, encfile = clean:match("([^%s]+)[%s]+([^%s]+)[%s]+<%[?(.+).enc")
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

local function make_checksum(htftable)
  local t =  {}
  for _, k in pairs(htftable) do
    table.insert(t,k[2])
  end
  return md5.sumhexa(table.concat(t))
  -- return table.concat(t)
end

local mapname = arg[1] or "libertine"
local encfile = kpse.find_file(mapname,"map")
-- local encfile = kpse.find_file("gfsdidot","map")
-- print(encfile)

print(template.head)

local htflib = require "htflib"
-- add suffix to the encoding htf file
-- we need to add suffix to prevent loading that file for normal fonts
local encoding_suff = "-ec"
local utfchar = unicode.utf8.char
local t = M.parse_map(encfile)
local checksums = {}
local missing_glyphs = {}
for encoding, fonts in pairs(t) do
  local htf,min,max, missing = htflib.make_htf(encoding)
  local htf_table = htflib.htf_table(encoding .. encoding_suff, htf, min, max)
  checksums[encoding] = make_checksum(htf)
  
  print(htflib.htf_container(encoding .. encoding_suff, "unicode/".. mapname .. "/", htf_table))
  for k,v in pairs(missing) do
    missing_glyphs[k] = v
  end
  -- reuse temp table
  local t = {}
  for fontname, properties in pairs(fonts) do
    t[#t+1]  = htflib.htf_container(fontname, "alias/".. mapname .. "/", string.format(".%s", encoding .. encoding_suff) .."\n".."htfcss: "..fontname .." "..fontproperties.make_css(properties))
  end
  print(table.concat(t,"\n\n"))
end

print(template.foot)
if next(missing_glyphs) ~= nil then
  print "% ----------------------"
  print "% Cannot load unicode values for following glyph names"
  print "% Please report these to htfgen issue tracker so we can "
  print "% add support for them\n"
  print ("% Glyph name", "encoding")
  print ("% ----------", "--------")
  for k, v in pairs(missing_glyphs) do
    print("% ".. k,v)
  end
end

for chk, cnt in pairs(checksums) do
  print(chk, cnt)
end
