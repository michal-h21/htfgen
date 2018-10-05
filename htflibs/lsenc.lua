-- list all used encodings in TeX font
kpse.set_program_name("luatex")
local lsenclib = require "htflibs.lsenc-lib"

local name = arg[1] or "ntxmia"

local print_enc = function(font,enc,fonttype,indent)
	local indent = string.rep("  ",indent)
  print(indent .. font, fonttype, enc)
end

local function print_r (rec, indent)
  local indent = indent or 0
  print_enc(rec.name, rec.enc, rec.font_type, indent)
  -- if the font is virtual, it may be composed from many other fonts
  if rec.children then
    for _, x in ipairs(rec.children) do
      print_r(x, indent + 1)
    end
  end

end

local encodings = lsenclib.get_encodings(name)
print_r(encodings)

