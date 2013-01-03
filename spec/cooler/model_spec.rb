require 'spec_helper'

describe Cooler::Model do
  describe 'initialize' do
    it 'should return an empty instance if not passing arguments' do
      instance = TestModel.new
      instance.foo.should be_nil
      instance.bar.should be_nil
    end

    it 'should populate attributes if passing a Hash' do
      instance = TestModel.new(foo: 'bar', nil: true)
      instance.foo.should == 'bar'
    end

    it 'should set its key' do
      instance = TestModel.new('keykey', foo: 'bar')
      instance._key.should == 'keykey'
      instance.foo.should == 'bar'
    end

    it 'should not modify passed attributes' do
      attrs = { 'foo' => 'bar' }
      instance = TestModel.new(attrs)
      attrs.should have_key('foo')
    end
  end

  describe '#key' do
    it 'should set its key to a new format' do
      TestModelNewKey.key { |i| "foo_bar_#{i.foo}" }
      t = TestModelNewKey.new(foo: 'baaar')
      t._key.should == 'foo_bar_baaar'
    end
  end

  describe '._key' do
    it 'should be the passed key' do
      instance = TestModel.new('keykey')
      instance._key.should == 'keykey'
    end

    it 'should be the constructed key if not passing one' do
      instance = TestModel.new
      instance._key.should == 'test_'
      instance.foo = 'bacon'
      instance._key.should == 'test_bacon'
    end

    it 'should return nil if no key block registered' do
      expect { TestModelNoKey.new._key.should be_nil }.to_not raise_error
    end

    it 'should be able to se its key' do
      instance = TestModel.new
      instance._key = 'CHUNKY'
      instance._key.should == 'CHUNKY'
    end
  end

  describe '#get' do
    it "should return the instance if Adapter's get block returns something" do
      mock(Cooler::Adapter).get do
        ->(key) { key.should == 'test_bacon' && { foo: 'bar' } }
      end
      instance = TestModel.get('test_bacon')
      instance.should be_an_instance_of(TestModel)
      instance._key.should == 'test_bacon'
      instance.foo.should == 'bar'
    end

    it 'should be nil if no results' do
      mock(Cooler::Adapter).get { ->(k) { nil } }
      TestModel.get('test_bacon').should be_nil
    end

    it 'should raise an error if no key defined and passing a Hash' do
      expect { TestModelNoKey.get(foo: 'bar') }.to raise_error
    end

    it 'should get the instance if passing a Hash' do
      mock(Cooler::Adapter).get do
        ->(key) { key.should == 'test_chunky' && { foo: 'bar' } }
      end
      instance = TestModel.get(foo: 'chunky')
      instance.should be_an_instance_of(TestModel)
      instance._key.should == 'test_chunky'
      instance.foo.should == 'bar'
    end
  end

  describe '#get!' do
    it 'should return the instance if found by Adapter' do
      mock(Cooler::Adapter).get do
        ->(k) { k.should == 'test_bacon' && { foo: 'bar' } }
      end
      instance = TestModel.get!('test_bacon')
      instance.should be_an_instance_of(TestModel)
      instance._key.should == 'test_bacon'
      instance.foo.should == 'bar'
    end

    it 'should raise an exception if no results' do
      mock(Cooler::Adapter).get { ->(k) { nil } }
      expect { TestModel.get!('test_bacon') }.
        to raise_error(Cooler::ObjectNotFound)
    end
  end

  describe '.attributes=' do
    before(:each) do
      @instance = TestModelUsingAttrAccessors.new
    end

    it 'should not do anything if not passing a Hash' do
      expect { @instance.attributes = [] }.to_not raise_error
    end

    it 'should assign class properties' do
      @instance.attributes = {'foo' => 'bar', chunky: 'BACON'}
      @instance.foo.should == 'bar'
      @instance.chunky.should == 'BACON'
    end

    it 'should assign attributes' do
      @instance.attributes = {'bar' => 'foo', bacon: 'CHUNKY'}
      @instance.bar.should == 'foo'
      @instance.bacon.should == 'CHUNKY'
    end

    it 'should not modify passed attributes' do
      @instance.attributes = attrs = { 'foo' => 'bar' }
      attrs.should have_key('foo')
    end
  end

  describe '.serializable_hash' do
    it 'should only include class properties' do
      instance = TestModelUsingAttrAccessors.new(foo: 'bar', bacon: 'CHUNKY')
      instance.serializable_hash.keys.should_not include(:bacon)
      instance.serializable_hash.keys.should include(:foo)
      instance.serializable_hash[:foo].should == 'bar'
    end

    it 'should allow an Array as a value' do
      instance = TestModelUsingAttrAccessors.new(foo: [1, 2, 3, 4])
      expect { instance.serializable_hash }.to_not raise_error
      instance.serializable_hash[:foo].should == [1, 2, 3, 4]
    end
  end

  context 'using attribute accessors' do
    it 'should assign the passed attribute when creating a new instance' do
      instance = TestModelUsingAttrAccessors.new(foo: 'chunky', bar: 'bacon')
      instance.foo.should == 'chunky'
      instance.bar.should == 'bacon'
    end
  end

  describe '#default' do
    it 'should raise an exception if no such attribute' do
      expect { TestModelWithDefaultValues.default :chunky }.
        to raise_error
    end

    it 'should set the default value using an Object' do
      TestModelWithDefaultValues.default :one, []
      TestModelWithDefaultValues.default :four, []
      instance = TestModelWithDefaultValues.new
      instance.one.should == []
      instance.four.should == []
    end

    it 'should set the default value using a block' do
      TestModelWithDefaultValues.default :two, -> { 3*3 }
      TestModelWithDefaultValues.default :four, lambda { 4*4 }
      TestModelWithDefaultValues.default :five, Proc.new { 5*5 }
      instance = TestModelWithDefaultValues.new
      instance.two.should == 9
      instance.four.should == 16
      instance.five.should == 25
    end

    it 'should set the default value using a block passing the instance' do
      TestModelWithDefaultValues.default :three, ->(i) { i.one }
      TestModelWithDefaultValues.default :six, lambda { |i| i.two }
      TestModelWithDefaultValues.default :seven, Proc.new { |i| i.four }
      instance = TestModelWithDefaultValues.new(one: '1', two: '2', four: '4')
      instance.three.should == '1'
      instance.six.should == '2'
      instance.seven.should == '4'
    end

    it 'should not set the default value if it already has another value' do
      TestModelWithDefaultValues.default :eight, 8
      TestModelWithDefaultValues.new(eight: '10').eight.should == '10'
    end
  end

  describe '.save!' do
    it 'should raise an exception if not saved' do
      mock(instance = TestModelForSave.new).save { false }
      expect { instance.save! }.to raise_error(Cooler::InvalidObject)
    end
  end

  describe '.save' do
    it "should call Adapter's set to save its attributes and fail" do
      instance = TestModelForSave.new(foo: 'bar', bar: 'BAR')
      mock(Cooler::Adapter).set do
        ->(key, value) do
          key.should == 'Chunky_BAR'
          value.should == { foo: 'bar' }
        end
      end
      mock(Cooler::Adapter).get { ->(k) { nil } }
      instance.save.should be_false
    end

    it 'should call Adapter to save its attributes and succed' do
      instance = TestModelForSave.new(foo: 'bar', bar: 'BAR')
      mock(Cooler::Adapter).set do
        ->(key, value) do
          key.should == 'Chunky_BAR'
          value.should == { foo: 'bar' }
        end
      end
      mock(Cooler::Adapter).get { ->(k) { k.should == 'Chunky_BAR' } }
      instance.save.should be_true
    end
  end

  describe '.create' do
    it 'should call Adapter to save its attributes' do
      mock(Cooler::Adapter).set do
        ->(key, value) do
          key.should == 'Chunky_BAR'
          value.should == { foo: 'bar' }
        end
      end
      mock(Cooler::Adapter).get do
        ->(k) { k.should == 'Chunky_BAR' && { foo: 'bar' } }
      end
      instance = TestModelForSave.create(foo: 'bar', bar: 'BAR')
      instance.should be_an_instance_of(TestModelForSave)
    end
  end
end
