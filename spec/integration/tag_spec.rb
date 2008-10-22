require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'Tag' do
  
  before do
    @tag = Tag.new
  end
  
  it "should have id and name columns" do
    @tag.attributes.should have_key(:id)
    @tag.attributes.should have_key(:name)
  end
end
