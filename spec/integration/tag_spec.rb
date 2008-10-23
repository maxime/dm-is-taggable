require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'Tag' do
  before :all do
    Tag.all.destroy!
  end
  
  before do
    @tag = Tag.new
  end
  
  it "should have id and name columns" do
    @tag.attributes.should have_key(:id)
    @tag.attributes.should have_key(:name)
  end
  
  it "should strip the tag name" do
    @tag.name = "blue "
    @tag.save
    @tag.name.should == "blue"
    second_tag = Tag.build("blue ")
    second_tag.should == @tag
  end
end
