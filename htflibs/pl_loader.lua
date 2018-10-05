local pl_loader = {}

local load_plist = function(prg,name)
  local command = prg .." "..name
  local prg = io.popen(command, "r")
  local result = prg:read("*all")
  prg:close()
  return result
end


pl_loader.load = function(name)
  local name = name or ""
  local filename = kpse.find_file(name,"vf")
  if not filename then
		return pl_loader.load_tfm(name), "tfm"
  end
  return load_plist("vftovp", filename), "vf"
end

pl_loader.load_tfm = function(name)
	local filename = kpse.find_file(name,"tfm")
	if not filename then
		return nil, "pl_loader: cannot find font file "..name
	end
	return load_plist("tftopl", filename) 
end

return pl_loader
