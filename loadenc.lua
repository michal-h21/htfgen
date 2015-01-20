kpse.set_program_name("luatex")
local loadenc = {}
local map 
loadenc.load = function(enc)
  local filename = kpse.find_file(enc,"enc files") or enc
  print(enc,filename)
	if not filename then return nil, "cannot load end ".. enc end
  local f = io.open(filename,"r")
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
  s:gsub("/([%a%.]+)", function(a)
    t[i] = a
    i = i + 1
  end)
  return t
end

local load_map = function()
	local mapfile = kpse.find_file("pdftex","map")
	print("mapfile",mapfile)
	if not mapfile then return nil, "cannot find pdftex.map" end
	--local mapfile = io.open(mapfile,"r")
	local t = {}
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
