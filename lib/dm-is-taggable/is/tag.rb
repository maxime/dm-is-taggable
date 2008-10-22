class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :unique => true

  def self.build(name)
    Tag.first(:name => name) || Tag.create(:name => name)
  end
end
