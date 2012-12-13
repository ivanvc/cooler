module Cooler
  # Defines the base methods to define a model class.
  module Model
    # Called after including in some class. For more information, read:
    # http://www.ruby-doc.org/core-1.9.3/Module.html#method-i-included
    #
    # Returns nothing.
    def self.included(base)
      base.send :extend, ClassMethods
      base.instance_variable_set :@default_values, {}
    end

    # Sets the key for an instance.
    attr_writer :_key

    # Defines class methods for a Model.
    module ClassMethods
      # Called after the class is inherited. It will copy its default
      # values, so subclass can use them too. For more informaiton, read:
      # http://www.ruby-doc.org/core-1.9.3/Class.html#method-i-inherited
      #
      # Returns nothing.
      def inherited(subclass)
        subclass.instance_variable_set :@default_values, default_values.dup
        subclass.instance_variable_set :@key_block, @key_block.dup
      end

      # Gets the default values.
      attr_reader :default_values

      # Define the key for documents of this instance.
      #
      # block    - A block that contains how to build the key for an instance.
      #            It receives the instance as an argument. This block should
      #            return a String.
      #
      # Examples
      #
      #   key { |click| ['click', click.app_key, click.tracking].join('_') }
      #   key do |install|
      #     ['install', install.app_key, install.finger_print].join('_')
      #   end
      #
      # Returns nothing if passing a block, the block if not passing it.
      def key(&block)
        if block_given?
          @key_block = block
        end
        @key_block || Proc.new { }
      end

      # Defines a default value for an attribute.
      #
      # attr  - The String or Symbol attribute name, to add the default value.
      # value - The Object to use as default value (optional).
      # block - A block to be run as default value (optional).
      #
      # Examples
      #
      #   default :clicks, []
      #   default :seconds, -> { Time.now.seconds }
      #   default :app_key, lambda { |install| install.app.key }
      #
      # Returns nothing.
      # Raises NameError if attribute does not exist.
      def default(attr, value, &block)
        unless instance_methods.include?("#{attr}=".to_sym) &&
          instance_methods.include?(attr.to_sym)
          raise NameError, "Unknown attribute #{attr}"
        end
        @default_values[attr.to_sym] = value || block
      end

      # Gets an Object from Couchbase, and construct an instance by its
      # key. In order to use Hash version, the class should define a key.
      #
      # key - The String that contains the key to query the object. Or the
      #       Hash with the value defined in the key to search. See examples
      #       for extra reference.
      #
      # Examples
      #
      #   class Install
      #     key { |i| "install_#{i.app_key}" }
      #   end
      #
      #   install = Install.get(app_key: '123')
      #   # => Gets object with key: 'install_123'
      #
      #   install = Install.get('install_123')
      #   # => Gets object with key: 'install_123'
      #
      # Return a Model instance or nothing if not found.
      # Raises NameError, if searching by key and key not defined.
      def get(key)
        if Hash === key
          raise NameError, 'Key not defined' unless @key_block
          key = @key_block.(OpenStruct.new(key))
        end
        result = Cooler::Adapter.get.(key) and new(key, result)
      end

      # Gets an Object from Couchbase, and construct an instance by its
      # key. Raises an error if not found.
      #
      # key - The String that contains the key to query the object.
      #
      # Return a Model instance.
      # Raises Cooler::KeyNotFound if not found. Compatible with
      # Sinatra::NotFound;
      # http://www.sinatrarb.com/intro.html#Not%20Found
      def get!(key)
        get(key) || raise(Cooler::KeyNotFound)
      end

      # Initializes a new instance, and saves it at the same time.
      #
      # attrs - May contain at the first position, the String key for the
      #         document owner of the instance. Then it a Hash with its
      #         attributes (default: {}).
      #
      # Returns the Object new instance.
      def create(*attrs)
        instance = new(*attrs)
        instance.save
        instance
      end
    end

    # Initialize a Base.
    #
    # attrs - May contain at the first position, the String key for the
    #         document owner of the instance. Then it a Hash with its
    #         attributes (default: {}).
    def initialize(*attrs)
      @_key = attrs.shift if String === attrs.first
      self.attributes = attrs.shift || {}
      set_default_values
    end

    # The key for the document.
    #
    # Returns the String key for this document.
    def _key
      @_key || self.class.key.(self)
    end

    # Assigns attributes from the passed Hash. Only setteable attributes
    # will be assigned.
    #
    # attributes - The Hash with the attributes to assign.
    #
    # Returns nothing.
    def attributes=(attributes)
      return unless Hash === attributes
      attributes = attributes.symbolize_keys
      attributes.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    # Provides basic serialization of the instance, it includes only
    # its Struct attributes, and not those defined from attr_accessor.
    #
    # Returns the serialized Hash.
    def serializable_hash
      Hash[*each_pair.map { |k, v| [k, v] }.flatten]
    end

    # Saves persisted attributes to the database.
    #
    # Returns true if saved, false if not.
    def save
      Cooler::Adapter.set.(_key, serializable_hash)
      !Cooler::Adapter.get.(_key).nil?
    end

    # Saves persisted attributes to the database. Raises an exception if
    # not able to save it.
    #
    # Returns nothing.
    # Raises Cooler::InvalidObject if not able to save it.
    def save!
      raise Cooler::InvalidObject unless save
    end

    private
    def set_default_values
      self.class.default_values.each do |key, value|
        if send(key).nil?
          if Proc === value
            value = value.arity.zero? ? value.() : value.(self)
          end
          send("#{key}=", value)
        end
      end
    end
  end
end
