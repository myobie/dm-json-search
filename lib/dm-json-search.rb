require 'dm-core'
require File.dirname(__FILE__) + '/dm-json-search/query_ext'
require File.dirname(__FILE__) + '/dm-json-search/searchable'

DataMapper::Model.append_extensions(JsonSearch::Searchable::ClassMethods)
# DataMapper::Model.append_inclusions(JsonSearch::Searchable::ClassMethods)