require "busted.runner" ()
kpse.set_program_name "luatex"

local fontobj = require "htflibs.fontobj"

describe("Fontobj test", function()
  local fonts = fontobj("libertine")
  fonts.maxvf = 10
  it("Should load the map file", function()
    assert.is_table(fonts.map)
  end)
  fonts:load_virtualfonts("public/libertine")
  -- fonts:load_font("LinLibertineO-tlf-t1")
end)
