kpse.set_program_name("luatex")

local fontproperties = require "fontproperties"
local loadenc = require "loadenc"
local glyphs = require "glyphload"
local template = require "litfonts-template"
local pfbparser = require "pfbparser"
local maplib = require "htflibs.maplib"

local function make_checksum(htftable)
  local t =  {}
  for _, k in pairs(htftable) do
    table.insert(t,k[3])
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
local t = maplib.parse_map(encfile)
local checksums = {}
local missing_glyphs = {}
-- save used pfbfiles 
local pfbfiles = {}
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
  for fontname, conf in pairs(fonts) do
    local properties = conf.properties
    t[#t+1]  = htflib.htf_container(fontname, "alias/".. mapname .. "/", string.format(".%s", encoding .. encoding_suff) .."\n".."htfcss: "..fontname .." "..fontproperties.make_css(properties))
    pfbfiles[conf.fontfile] = true
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


local saved_checksums = {}
for enc, cnt in pairs(checksums) do
  local encodings = saved_checksums[cnt] or {}
  encodings[#encodings+1] = enc
  saved_checksums[cnt] = encodings
  -- print(chk, cnt)
end

local i = 1
for k,v in pairs(saved_checksums) do
  print(i, k, #v)
  i = i + 1
end

for name, _ in pairs(pfbfiles) do
  familyname, styles = pfbparser.parse_pfbfile(kpse.find_file(name,"type1 fonts"))
  print(familyname, fontproperties.make_css(familyname .. styles))
end
