
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

local parse_glyphlist = function()
  local t = {}
	local glyphlist = kpse.find_file("glyphlist.txt","map")
	local texglyphs = kpse.find_file("texglyphlist.txt","map")
	t = load_glyphlist(glyphlist, t)
	t = load_glyphlist(texglyphs, t)
  return t
end


return parse_glyphlist()
