local M = {}

function M.make_css(fontname, propertystring)
  local bold = propertystring:match("bold") and "font-weight: bold;"
  local slanted = propertystring:match("slanted") and "font-style: oblique;"
  local italic = propertystring:match("italic") and "font-style: italic;"
  local smallcaps = (propertystring:match("sc") or propertystring:match("smallcaps")) and "font-variant: small-caps;"
  local sans = propertystring:match("sans") and "sans-serif"
  local mono = propertystring:match("mono") and "monospace"
  local cssfontname = string.format("font-name: '%s', %s", fontname,(mono or sans) or "serif")
  local t = {}
  table.insert(t,bold)
  table.insert(t,slanted)
  table.insert(t,italic)
  table.insert(t,smallcaps)
  table.insert(t,cssfontname)
  return table.concat(t, " ")
end

return M
