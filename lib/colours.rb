module Colours
  Pair = Struct.new('Pair', :background, :text) do
    def css_text_style
      "background-color: ##{background}; color: ##{text}"
    end
  end

  # We define colours globally, for all known operand family types, so that there's consistency
  # between different architectures
  # 
  # Some colours pinched from https://fabianburghardt.de/swisscolors/
  OPERAND_FAMILY_COLOURS = {
    "Immediate" => Pair.new("37bbe4", "35342f"), # light blue - dark grey
    "Memory" => Pair.new("f0c24f", "35342f"), # yellow/green - dark grey

    "Address register" => Pair.new("fca85d", "35342f"), # light orange - dark grey
    "Data register" => Pair.new("fe9f97", "35342f"), # light pink - dark grey
    "General-purpose register" => Pair.new("08327d", "fbfbfb"), # dark blue - white
    "General-purpose register" => Pair.new("08327d", "fbfbfb"), # dark blue - white

    "Other register" => Pair.new("db2f27", "fbfbfb"), # red - white

    # x86-specific
    "x87 floating-point register" => Pair.new("0d6e25", "fbfbfb") # green - white
  }

  # For operand types with no colour
  DEFAULT = Pair.new("ffffff", "000000") # white - black
end
