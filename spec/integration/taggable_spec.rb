require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'DataMapper::Is::Taggable' do
  before :all do
    Post.all.destroy!
  end
  
  before :each do
    @post = Post.create(:name => "My First Post")
    @blue = Tag.build('blue')
    @yellow = Tag.build('yellow')
  end
  
  it "should add a taggable? method that return true" do
    Post.should respond_to(:taggable?)
    Post.taggable?.should == true
  end
  
  it "should add a tag method for tagging purposes" do
    @post.should respond_to(:tag)
  end
  
  it "should add a tags method for getting all the tags in an array" do
    @post.should respond_to(:tags)
    @post.tags.should be_empty
  end
  
  it "should be able to tag a post" do
    @post.tag(@blue)
    @post.tags.should have(1).thing
    @post.tags.should include(@blue)
    
    @post.tag(@yellow)
    @post.tags.reload # otherwise, it won't be updated
    @post.tags.should have(2).things
    @post.tags.should include(@blue)
    @post.tags.should include(@yellow)    
  end
end
