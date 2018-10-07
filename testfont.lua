local font = arg[1]
if not font then 
	print("Usage: testfont fontname")
	print("Files fontname.pdf and fontname.html will be created")
	os.exit()
end

local template = [[
\documentclass{article}
\pagestyle{empty}
\begin{document}
\font\x= ${font}
\count0=0
\loop
\ifnum\count0<256
\the\count0\ \bgroup\x\char\count0\egroup\ \Picture+{}\char\count0\EndPicture\par
\advance\count0 by1\relax
\repeat
\end{document}
]]

template = template:gsub("${font}", font)

-- local pdflatex = io.popen("pdflatex -jobname="..font,"w")
-- pdflatex:write(template)
-- pdflatex:close()

template = '\\RequirePackage[xhtml,charset=utf-8]{tex4ht}' .. template

local htlatex = io.popen("latex -jobname="..font,"w")
htlatex:write(template)
htlatex:close()

os.execute("tex4ht -cunihtf -utf8 "..font)
os.execute("t4ht "..font)
