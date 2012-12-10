module Cooler
  # Defines functions to get and set keys from the database.
  class Adapter
    class << self
      # Gets the get block.
      attr_reader :get

      # Gets the set block.
      attr_reader :set
    end

    # Sets the block that handles getting a key.
    #
    # block - The block that receives as argument the String with the
    #         queried key.
    #
    # Examples
    #
    #   Cooler::Adapter.get = ->(key) { redis.get(key) }
    #   Cooler::Adapter.get = Proc.new do |key|
    #     couchbase[key]
    #   rescue Couchbase::NotFound
    #     nil
    #   end
    #
    # Returns nothing.
    def self.get=(block)
      raise 'Argument must be a block' unless Proc === block
      @get = block
    end

    # Sets the block that handles storing a key.
    #
    # block - The block that receives as argument the String with the
    #         queried key, and serialized object.
    #
    # Examples
    #
    #   Cooler::Adapter.set = ->(key, value) { couchbase[key] = value }
    #   Cooler::Adapter.get = lambda do |key, value|
    #     redis.set(key, value.to_json)
    #   end
    #
    # Returns nothing.
    def self.set=(block)
      raise 'Argument must be a block' unless Proc === block
      @set = block
    end
  end
end
