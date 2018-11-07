require "busted.runner" ()
kpse.set_program_name "luatex"

local htflib = require "htflibs.htflib"
local fontobj = require "htflibs.fontobj"

describe("Fontobj test", function()
  -- local fonts = fontobj("libertine")
  local fonts = fontobj("pdftex")

  fonts.maxvf = 10
  it("Should load the map file", function()
    assert.is_table(fonts.map)
  end)
  describe("load virtual font", function()
    local fontobj = fonts:load_virtual_font(kpse.expand_var("$TEXMFDIST") .. "/fonts/vf/public/libertine/LinLibertineT-tlf-sc-t1.vf")
    it("Should parse the font", function()
      assert.is_table(fontobj)
      assert.is_same(0, fontobj.min)
      assert.is_same(255, fontobj.max)
      assert.is_same("LinLibertineT-tlf-sc-t1", fontobj.font_file)
      assert.is_string(fontobj.hash)
    end)
    it("Should parse the characters", function()
      assert.is_table(fontobj.characters)
      -- the character on position 254 is thorn in small caps
      local char = fontobj.characters[254]
      assert.is_same(char[1], 254)
      assert.is_same(char[2], "thorn.sc")
      assert.is_same(char[3], "&#x00FE;")
    end)
    it("Style parsing should work", function()
      local style = fontobj.style
      assert.is_table(style)
      assert.is_same(style.familyname, "Linux Libertine T")
    end)
    -- print(htflib.fontobj_to_htf_table(fontobj))
  end)
  -- fonts:load_virtual_font(kpse.expand_var("$TEXMFDIST") .. "/fonts/vf/public/newtx/ntxmia.vf", "ntxmia")
  -- fonts:load_virtual_fonts("public/libertine")
  -- fonts:load_font("LinLibertineO-tlf-t1")
end)
