include DataMapper::Sweatshop::Unique

class Book
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  belongs_to :author
end

class Author
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :books
  belongs_to :place
end

class Place
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :authors
end

Book.fixture {{
  :title => ((/\w{10}/.gen+' ')*2).strip,
  :author => Author.make
}}

Author.fixture {{
  :name => ((/\w{10}/.gen+' ')*2).strip,
  :place => Place.make
}}

Place.fixture {{
  :name => ((/\w{10}/.gen+' ')*2).strip
}}