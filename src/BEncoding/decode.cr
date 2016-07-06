module BEncoding
  DECODE_BYTES = {
    :dictionary_start => 'd'.bytes[0],
    :dictionary_end   => 'e'.bytes[0],
    :list_start       => 'l'.bytes[0],
    :list_end         => 'e'.bytes[0],
    :number_start     => 'i'.bytes[0],
    :number_end       => 'e'.bytes[0],
    :bytea_divider    => ':'.bytes[0],
  }

  class ByteIterator
    include Iterator(UInt8)

    def initialize(@bytes : Array(UInt8))
      @pointer = 0
    end

    def pointer
      @pointer
    end

    def current
      @bytes[@pointer]
    end

    def next
      if @pointer < @bytes.size
        val = @bytes[@pointer]
        @pointer = @pointer + 1
        return val
      else
        stop
      end
    end
  end

  class Decode
    alias ElementMember = String | Int32 | UInt8 | Hash(String, ElementMember) | Nil
    alias DecodedElements = Array(ElementMember)

    @reader : File
    @elements : DecodedElements

    def self.decode(file_path : String)
      new(file_path).decode
    end

    def initialize(@file_path : String)
      @reader = File.open(@file_path)
      @elements = DecodedElements.new
    end

    def decode
      puts "--- Starting Decode of #{@file_path} ---".colorize(:red)
      bytes = [] of UInt8
      @reader.each_byte do |byte|
        bytes.push(byte)
      end
      byte_iterator = ByteIterator.new(bytes: bytes)
      byte_iterator.each do |byte|
        @elements.push(decode_byte(byte, byte_iterator))
      end
      puts @elements
    end

    def decode_byte(byte : UInt8, byte_iterator : ByteIterator)
      case DECODE_BYTES.invert.fetch(byte, :content)
      when :dictionary_start
        decode_dictionary(byte_iterator)
      when :list_start
        decode_list(byte_iterator)
      when :number_start
        decode_number(byte_iterator)
      else
        decode_bytea(byte_iterator)
      end
    end

    def decode_bytea(byte_iterator : ByteIterator) : String
      bytes = [] of UInt8
      byte_iterator.each do |byte|
        break if DECODE_BYTES[:bytea_divider] == byte
        bytes.push(byte)
      end
      String.new(Slice.new(bytes.to_unsafe, bytes.size))
    end

    def decode_dictionary(byte_iterator : ByteIterator)
      puts "--- Starting Dictionary ---".colorize(:red)
      hash = {} of String => ElementMember
      byte_iterator.each do |byte|
        break if byte == DECODE_BYTES[:dictionary_end]
        key = decode_bytea(byte_iterator)
        obj = decode_byte(byte, byte_iterator)
        # hash[key] = obj
      end
      return hash
    end

    def decode_list(byte_iterator : ByteIterator)
      puts "--- Starting List ---".colorize(:red)
      byte_iterator.each do
        if DECODE_BYTES[:list_end] == byte_iterator.current
          puts "BREAK LIST"
          break
        else
          # puts "LIST BYTE: #{byte_iterator.pointer}"
        end
      end
    end

    def decode_number(byte_iterator : ByteIterator)
      puts "--- Starting Number ---".colorize(:red)
      decode_bytea(byte_iterator).to_i
    end
      
  end
end