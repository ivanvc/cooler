module Cooler
  # Defines functions to get and set keys from the database.
  class Adapter
    class << self
      # Gets the get block.
      attr_reader :get

      # Gets the set block.
      attr_reader :set

      # Gets the delete block.
      attr_reader :delete
    end

    # Sets the block that handles getting a key.
    #
    # block - The block that receives as argument the String with the
    #         queried key. It should return a Hash.
    #
    # Examples
    #
    #   Cooler::Adapter.get = ->(key) { JSON.parse(redis.get(key)) }
    #   Cooler::Adapter.get = Proc.new do |key|
    #     begin
    #       couchbase[key]
    #     rescue Couchbase::NotFound
    #       puts 'uh oh'
    #     end
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

    # Sets the block that handles deleting a key.
    #
    # block - The block that receives as argument the String with the key to
    #         delete.
    #
    # Examples
    #
    #   Cooler::Adapter.delete = ->(key) { redis.del(key) }
    #
    # Returns nothing.
    def self.delete=(block)
      raise 'Argument must be a block' unless Proc === block
      @delete = block
    end
  end
end
