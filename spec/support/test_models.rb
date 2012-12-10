class TestModel < Struct.new(:foo, :bar)
  include Cooler::Model
  key { |i| "test_#{i.foo}" }
end

class TestModelNewKey < Struct.new(:foo, :bar)
  include Cooler::Model
end

class TestModelDuplicateAttrs < Struct.new(:foo, :bar)
  include Cooler::Model
end

class TestModelNoAttrs
  include Cooler::Model
end

class TestModelNoKey
  include Cooler::Model
end

class TestModelUsingAttrAccessors < Struct.new(:foo, :chunky)
  include Cooler::Model
  attr_accessor :bar, :bacon
end

class TestModelWithDefaultValues < Struct.new(:one, :two, :three)
  include Cooler::Model
  attr_accessor :four, :five, :six, :seven, :eight, :nine
end

class TestModelForSave < Struct.new(:foo)
  include Cooler::Model
  attr_accessor :bar
  key { |i| "Chunky_#{i.bar}" }
end
