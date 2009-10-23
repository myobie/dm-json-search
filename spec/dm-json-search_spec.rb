require File.dirname(__FILE__) + '/spec_helper'

describe "dm-json-search" do
  
  before do
    DataMapper.auto_migrate!
  end
  
  should "produce the same json it wants to consume" do
    j = Book.all(:author => Author.all(:place => Place.all)).query.to_json
    k = Book.all_from_json(j).query.to_json
    j.should == k
    
    j = Book.all(:title.like => "foo").query.to_json
    k = Book.all_from_json(j).query.to_json
    j.should == k
  end
  
end
