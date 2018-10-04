local M = {}

local function parse_line(line)
  local line = line or ""
  local clean = line:gsub('%b""',"")
  local fontname, properties, encfile, pfbfile = clean:match("([^%s]+)[%s]+([^%s]+)[%s]+<%[?(.+).enc[%s]+<(.+)")
  return fontname, properties, encfile, pfbfile
end
function M.parse_map(filename) 
  local t = {}
  for line in io.lines(filename) do
    local fontname, properties, encoding, pfbfile =  parse_line(line) 
    if fontname then
      -- get fonts with current encoding
      local encfonts = t[encoding] or {}
      encfonts[fontname] = {properties = properties, fontfile = pfbfile}
      -- save updated fonts 
      t[encoding] = encfonts 
    end
  end
  return t
end

return M
