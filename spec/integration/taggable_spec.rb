require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'DataMapper::Is::Taggable' do
  before :all do
    Post.all.destroy!
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
  
  # Post tagging
  
  it "should be able to tag an object" do
    @post.tag(@blue)
    @post.tags.reload
    @post.tags.should have(1).thing
    @post.tags.should include(@blue)
    
    @post.tag(@yellow)
    @post.tags.reload
    @post.tags.should have(2).things
    @post.tags.should include(@blue)
    @post.tags.should include(@yellow)    
  end
  
  # Get post from tags
  it "should be able to get objects tagged with a tag" do
    @yellow.posts.should have(1).thing
    @yellow.posts.first.should == @post

    @blue.posts.should have(1).thing
    @blue.posts.first.should == @post
  end
  
  # Post Untagging
  it "should be able to untag" do
    @post.untag(@blue)
    @post.tags.reload
    @post.tags.should_not include(@blue)
    
    @blue.posts.reload
    @blue.posts.should be_empty
  end
end
