require 'cooler/version'
require 'cooler/errors'
require 'active_support/core_ext/hash/keys'
require 'ostruct'

module Cooler
  autoload :Model,   'cooler/model.rb'
  autoload :Adapter, 'cooler/adapter.rb'
end
