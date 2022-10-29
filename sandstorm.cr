require "file_utils"

enum COLOR_TYPE
  Background
  Color
  Border
end

COLOR_TYPE_NAMES = COLOR_TYPE.names.map { |x| x.downcase }

def rgb(r : Int32, g : Int32, b : Int32, color_type : COLOR_TYPE = :COLOR) : String
  type = color_type.to_s.downcase
  ".rgb-#{r}-#{g}-#{b}{#{type}#{color_type.color? ? nil : "-color"}:rgb(#{r},#{g},#{b});}"
end

def hsl(h : Int32, s : Int32, l : Int32, color_type : COLOR_TYPE = :COLOR) : String
  type = color_type.to_s.downcase
  ".hsl-#{h}-#{s}-#{l}{#{type}#{color_type.color? ? nil : "-color"}:hsl(#{h},#{s}%,#{l}%);}"
end

def rgb_to_hex(r : Int32, g : Int32, b : Int32) : String
  {r, g, b}.map { |x| x.to_s(16).rjust(2, '0') }.join
end

def hex(r : Int32, g : Int32, b : Int32, color_type : COLOR_TYPE = :COLOR) : String
  type = color_type.to_s.downcase
  r2h = rgb_to_hex(r, g, b)
  ".hex-#{r2h}{#{type}#{color_type.color? ? nil : "-color"}:##{r2h};}"
end

FILENAME        = "sandstorm"
OUT_DIR         = "output"
FILENAME_SUFFIX = {
  rgb: "rgb",
  hex: "hex",
  hsl: "hsl",
}

FileUtils.rm_rf(OUT_DIR)
FILENAME_SUFFIX.each_key do |k|
  COLOR_TYPE_NAMES.each do |type|
    Dir.mkdir_p(Path[OUT_DIR, k.to_s, type])
  end
end

def gen_all_3_arg_colors(x : Int32, y : Int32, z : Int32, &block)
  (0..x).each do |c1|
    (0..y).each do |c2|
      (0..z).each do |c3|
        yield c1, c2, c3
      end
    end
  end
end

def file_path(color_type : String, suffix : String) : Path
  Path[OUT_DIR, suffix, color_type, "#{FILENAME}-#{color_type}-#{suffix}.css"]
end

COLOR_TYPE_NAMES.each do |color_type|
  cte = COLOR_TYPE.parse(color_type)

  File.open(file_path(color_type, FILENAME_SUFFIX[:rgb]), "w") do |file|
    gen_all_3_arg_colors(255, 255, 255) do |r, g, b|
      file.print rgb(r, g, b, cte)
    end
  end

  File.open(file_path(color_type, FILENAME_SUFFIX[:hex]), "w") do |file|
    gen_all_3_arg_colors(255, 255, 255) do |r, g, b|
      file.print hex(r, g, b, cte)
    end
  end

  File.open(file_path(color_type, FILENAME_SUFFIX[:hsl]), "w") do |file|
    gen_all_3_arg_colors(359, 100, 100) do |h, s, l|
      file.print hsl(h, s, l, cte)
    end
  end
end
