-- I tried to list all tfm files and collect used encodings, but it seems
-- that it is impossible.
--
kpse.set_program_name("luatex")
local pl = require "pl_loader"

local texmf = kpse.expand_var("$TEXMFDIST") .. "/fonts/tfm"

local command = io.popen("find "..texmf .." -name *.tfm","r")
local result = command:read("*all")
command:close()

local get_enc = function(f)
	local cmd = assert(io.popen("tftopl "..f, "r"))
	local res,status = cmd:read("*all")
	cmd:close()
	local enc = res:match("CODINGSCHEME ([^%)]*)") or "undefined"
	if not enc  then print("error",f) end
	return enc
end

local encodings = {}
for i,line in ipairs(result:explode("\n")) do
	local enc =  get_enc(line)
	local i = encodings[enc] or 0
	i = i + 1
	encodings[enc] = i
end


for k,v in pairs(encodings) do
	print(k,v)
end

