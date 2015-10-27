local basedir = arg[0]:match("(.+)/[^%/]+") or "."
basedir = basedir .. "/"
local load_glyphlist = function(file, t)
	local t = t or {}
	if not file then return t, "No glyph list file" end
  for line in io.lines(file) do
    local glyph, hex = line:match("([%a%.0-9%_]+);([%a0-9 ]+)")
    if glyph then
      hex = hex:gsub("%s*$","")
      t[glyph] = hex
    end
  end
	return t
end

local load_alt_glyphs = function(t)
	for line in io.lines(basedir .. "altglyphs.txt") do
		if not line:match("^%s*#") then
			line = line:gsub("#.*","")
			local hex = line:match("0x([a-f0-9]+)")
			if hex then 
				hex = hex:upper()
				local c = string.explode(line," ")
				c[#c] = nil
				for _,item in ipairs(c)  do
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
  t = load_glyphlist(basedir .. "unimathsymbols.txt",t)
	t = load_glyphlist(basedir .. "additional-glyphlist.txt", t)
	t = load_glyphlist(basedir .. "goadb100.txt", t)
	t = load_alt_glyphs(t)
	t = load_glyphlist(basedir .. "glyphlist-extended.txt", t)
  t =  setmetatable({},{__index = t})
	t.getGlyph = function(self,x)
		local x = x or ""
		local y = self[x]  
		if y then return y end
		local c =  x:match("u[n]?[i]?([A-Fa-f0-9]+)")
		return c
	end
	return t
	--]]
end


return parse_glyphlist()
