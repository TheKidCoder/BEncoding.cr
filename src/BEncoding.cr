require "colorize"
require "./BEncoding/*"

module BEncoding
  def self.decode_file(path : String)
    if File.file?(path)
      BEncoding::Decode.decode(path)
    else
      raise ArgumentError.new("File Not Found: #{path}")
    end

  end
end


BEncoding.decode_file("spec/test.torrent")

