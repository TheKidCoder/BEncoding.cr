require "./spec_helper"

describe BEncoding do

  it "takes decodes an actual file path" do
    BEncoding.decode_file("").should expect_raises(ArgumentError)
  end
end
