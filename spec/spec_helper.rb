require "bacon"
require "mocha"
require File.dirname(__FILE__) + "/../lib/dm-json-search"

require 'dm-sweatshop'
require File.join(File.dirname(__FILE__), 'spec_fixtures')

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.auto_migrate!

class Proc
  def increase?
    pre_result = yield
    called = call
    post_result = yield
    pre_result < post_result
  end
  
  def decrease?
    pre_result = yield
    called = call
    post_result = yield
    pre_result > post_result
  end
end

# from 1 to 10 how likely, 1 being not very likely and 10 being all the time
def do_i?(i = 5)
  rand(500) < 50 * i
end




##
# Hash additions.
#
# From 
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly

class Hash

  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }
  
  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }
  
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end

end