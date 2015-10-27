#!/usr/bin/env texlua
function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

local fontname = arg[1]
if not fontname then 
  print [[
  use tfmgen fontname
  ]]
  os.exit(1)
end

local template = [[
\documentclass{article}
\usepackage[xhtml,ShowFont]{tex4ht}
\begin{document}
\font\x={font}
\ShowFont\x
\end{document}
]]

template = template:gsub("{font}",fontname)
--local tex = io.popen("latex -jobname="..fontname.." -interaction=batchmode", "w")
local tex = io.popen("latex -jobname="..fontname, "w")
tex:write(template)
tex:close()
if not file_exists(fontname..".dvi") then
  print("Fatal error: LaTeX run failed")
  os.exit(1)
end

os.execute("tex4ht "..fontname)
local html_file = io.open(fontname ..".html","r")
local html = html_file:read("*all")
html_file:close()
local table = html:match('alt="(.*)"  class="ShowFont"')

print(table)

