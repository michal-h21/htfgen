local M = {}

local function parse_line(line)
  local line = line or ""
  local clean = line:gsub('%b""',"")
  local fontname, properties, encfile, pfbfile = clean:match("([^%s]+)[%s]+([^%s]+)[%s]+<%[?(.+).enc[%s]+<%s*([^%s]+)")
  return fontname, properties, encfile, pfbfile
end
function M.parse_map(filename) 
  local t = {}
  local fonts = {}
  for line in io.lines(filename) do
    local fontname, properties, encoding, pfbfile =  parse_line(line) 
    if fontname then
      -- get fonts with current encoding
      local encfonts = t[encoding] or {}
      local record = {properties = properties, fontfile = pfbfile, encoding = encoding}
      encfonts[fontname] = record
      fonts[fontname] = record
      -- save updated fonts 
      t[encoding] = encfonts 
    end
  end
  -- return encodings and fonts
  return t, fonts
end

return M
