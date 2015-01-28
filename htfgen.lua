kpse.set_program_name("luatex")
local input =arg[1]

--local name =  input:match("([^/]+)%.?[t]?[s]?[v]?")
local name =  input:match("([^/]+)%.tsv") 


local min = nil
local max = 0 

local htf = {}
for line in io.lines(input) do
	local t = string.explode(line,"\t")
	local i = tonumber(t[1]) 
	if min then
	  min = math.min(min,i)
	else
		min = i
	end
	max = math.max(max,i)
	htf[#htf+1] = {t[3],t[2]}
end

print(name.." "..min.." "..max)
for _,c in ipairs(htf) do
	print("'&#x"..c[1]..";'", "''", c[2])

end
print(name.." "..min.." "..max)

