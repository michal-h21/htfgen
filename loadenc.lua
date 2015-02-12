kpse.set_program_name("luatex")
local loadenc = {}
local map 
loadenc.load = function(enc)
	--print("enc",enc)
  local filename = kpse.find_file(enc,"enc files") or enc
  --print(enc,filename)
	if not filename then return nil, "cannot load end ".. enc end
  local f = io.open(filename,"r")
	if not f then return nil, "cannot load enc "..enc end
  local contents = f:read("*all")
  f:close()
  local encoding = contents:match("/[^%s]+%s*%[(.-)%]%s*def")
  encoding = encoding:gsub("%%[^\n]*","")
  return encoding
end

loadenc.parse = function(s)
	local s = s or ""
  local t = {}
  local i = 0
  s:gsub("/([%a%.0-9]+)", function(a)
    t[i] = a
    i = i + 1
  end)
  return t
end


local mapfolder = kpse.expand_var("$TEXMFDIST") .. "/fonts/map/pdftex"
local load_maps = function(t)
	local t = t or {}
	for dir in lfs.dir(mapfolder) do
		local s = dir:match("(.)")
		if s~= "." then
			local path = mapfolder .."/"..dir
			for file in lfs.dir(path) do
				if file:match "map$" then
					local filename = path .."/"..file
					for line in io.lines(filename) do
						t[#t+1] = line
					end
				end
			end
		end
	end
	return t
end

local load_map = function()
	local mapfile = kpse.find_file("pdftex","map")
	--print("mapfile",mapfile)
	if not mapfile then return nil, "cannot find pdftex.map" end
	--local mapfile = io.open(mapfile,"r")
	local t = {}
	t = load_maps(t)
	for line in io.lines(mapfile) do
		t[#t+1] = line
	end
	map = table.concat(t,"|") 
	return map
end

loadenc.find = function(name)
	local map = map or load_map() or ""
	local line = map:match("|"..name .. "(.-)|")
	if not line then return nil, "cannot find font "..name end
	local enc =  line:match("<%s*(.-)%.enc")
	return enc
end


-- k = loadenc.load("ntxmiaalt")
-- loadenc.parse(k)

return loadenc
