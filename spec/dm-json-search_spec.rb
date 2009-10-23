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
  
  should "run the query" do
    j = Book.all(:author => Author.all(:place => Place.all)).query.to_json
    Book.all_from_json(j).class.should == DataMapper::Collection
  end
  
  should "fetch the correct book" do
    Book.auto_migrate!
    Book.gen
    Book.gen(:title => "foo")
    
    books = Book.all_from_json('[{"eql":{"Book.title":"foo"}}]')
    books.length.should == 1
    books.first.title.should == "foo"
  end
  
end
