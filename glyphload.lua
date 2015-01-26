
local load_glyphlist = function(file, t)
	local t = t or {}
	if not file then return t, "No glyph list file" end
  for line in io.lines(file) do
    local glyph, hex = line:match("([%a]+);([%a0-9]+)")
    if glyph then
      t[glyph] = hex
    end
  end
	return t
end

local load_alt_glyphs = function(t)
	for line in io.lines("altglyphs.txt") do
		if not line:match("^%s*#") then
			line = line:gsub("#.*","")
			local hex = line:match("0x([a-f0-9]+)")
			if hex then 
				hex = hex:upper()
				local c = string.explode(line," ")
				c[#c] = nil
				for _,item in ipairs(c)  do
					print(item, hex)
					t[item] = hex
				end
			end
		end
	end
	return t
end

local parse_glyphlist = function()
  local t = {}
	local glyphlist = kpse.find_file("glyphlist.txt","map")
	local texglyphs = kpse.find_file("texglyphlist.txt","map")
	t = load_glyphlist(glyphlist, t)
	t = load_glyphlist(texglyphs, t)
	t = load_alt_glyphs(t)
	--[[
  return setmetatable(t,{__index = function(x) 
		local x = x or "" 
		local c =  x:match("u([A-Fa-f0-9]+)") or ""
		print("lookup ",c)
		return ""
	end})
	--]]
	return t
end


return parse_glyphlist()
