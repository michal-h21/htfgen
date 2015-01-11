kpse.set_program_name("luatex")
local loadenc = {}

loadenc.load = function(enc)
  local filename = kpse.find_file(enc,"enc files")
  print(filename)
  local f = io.open(filename,"r")
  local contents = f:read("*all")
  f:close()
  local encoding = contents:match("/[^%s]+%s*%[(.-)%]%s*def")
  encoding = encoding:gsub("%%[^\n]*","")
  return encoding
end

loadenc.parse = function(s)
  local t = {}
  local i = 0
  s:gsub("/([%a%.]+)", function(a)
    print(i,a)
    t[i] = a
    i = i + 1
  end)
  return t
end


k = loadenc.load("ntxmiaalt")
loadenc.parse(k)

return loadenc
