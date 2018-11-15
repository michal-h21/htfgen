local M = {}

local function parse_line(line)
  local line = line or ""
  local clean = line:gsub('%b""',"")
  local fontname, properties, encfile, pfbfile = clean:match("([^%s]+)[%s]+([^%s]+)[%s]+<%[?(.+).enc[%s]+<%s*([^%s]+)")
  if not fontname then
    fontname, properties, pfbfile = clean:match("([^%s]+)%s+([^%<]+)%<(.-%.pfb)")
  end
  return fontname, properties, encfile, pfbfile
end
function M.parse_map(filename) 
  local t = {}
  local fonts = {}
  for line in io.lines(filename) do
    local fontname, properties, encoding, pfbfile =  parse_line(line) 
    if fontname then
      local record = {properties = properties, fontfile = pfbfile, encoding = encoding}
      -- save updated fonts 
      fonts[fontname] = record
      if encoding then
        -- get fonts with current encoding
        local encfonts = t[encoding] or {}
        encfonts[fontname] = record
        t[encoding] = encfonts 
      end
    end
  end
  -- return encodings and fonts
  return t, fonts
end

return M
