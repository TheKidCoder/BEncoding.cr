require "./BEncoding/*"

module BEncoding
  def self.decode_file(path : String)
    if File.exists?(path)
      BEncoding::Decode.new(path)
    else
      raise ArgumentError.new("File Not Found: #{path}")
    end

  end
end


BEncoding.decode_file("nope.torrent")

