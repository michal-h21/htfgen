local parsepl = require "htflibs.parsepl"
local pl_loader = require "pl_loader"

local M = {}

local find_enc = function(pl)
  for k,v in ipairs(pl) do
    if v.type == "encoding" then
      return v.value
    end
  end
end


local function make_font_record(name, fonttype, enc)
  return {name = name, font_type = fonttype, enc = enc}
end

local function list_fonts(t, indent)
  local used_fonts = {}
	for k,v in ipairs(t) do
		if v.type=="mapfont" then
			local j,fonttype = pl_loader.load(v.name)
			--print(v.name, j:len())
			local pl = parsepl.parse(j)
      local enc = find_enc(pl)
			-- print_enc(v.name,enc,fonttype,indent)
      local current_font = make_font_record(v.name, fonttype, enc)
			if fonttype == "vf" then
				current_font.children = list_fonts(pl,indent+1)
			end
      table.insert(used_fonts, current_font)
		end
	end
  return used_fonts
end

local function get_encodings(name)
  local s, fonttype = pl_loader.load(name)
  local t = parsepl.parse(s)

  local enc = find_enc(t)
  -- print_enc(name,enc,fonttype,0)
  local current_font = make_font_record(name, fonttype, enc)
  

  if fonttype == "vf" then
    current_font.children = list_fonts(t,1)
  end
  return current_font
end

M.get_encodings = get_encodings
return M

