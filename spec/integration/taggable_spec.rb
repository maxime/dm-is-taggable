require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'DataMapper::Is::Taggable' do
  before :all do
    Post.all.destroy!
    @post = Post.create(:name => "My First Post")
    @blue = Tag.build('blue')
    @yellow = Tag.build('yellow')
    
    Book.all.destroy!
    @book = Book.create(:title => "Wonderful world", :isbn => "1234567890123", :author => "Awesome author")
    @fiction = Tag.build('fiction')
    @english = Tag.build('english')
    
    User.all.destroy!
    @bob = User.create(:login => 'bob')
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
  
  it "should add a tag_list method for getting the tag list" do
    @post.tags_list.should == ""
    
    @post.tag(@blue)
    @post.reload
    @post.tags_list.should == "blue"
    
    @post.tag(@yellow)
    @post.reload
    @post.tags_list.should == "blue, yellow"
    
    @post.untag(@blue)
    @post.untag(@yellow)
    
    @post.reload
    @post.tags_list.should == ""
  end
  
  # Post tagging
  it "should be able to tag a post" do
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
  it "should be able to get posts tagged with a tag" do
    @yellow.posts.should have(1).thing
    @yellow.posts.first.should == @post

    @blue.posts.should have(1).thing
    @blue.posts.first.should == @post
  end
  
  # Post Untagging
  it "should be able to untag a post" do
    @post.untag(@blue)
    @post.tags.reload
    @post.tags.should_not include(@blue)
    
    @blue.posts.reload
    @blue.posts.should be_empty
  end
  
  # Book tagging
  it "should be able to tag a book without tagger" do
    @book.tag(@fiction)
    @book.tags.reload
    @book.tags.should have(1).thing
    @book.tags.should include(@fiction)
    
    @book.tag(@english)
    @book.tags.reload
    @book.tags.should have(2).things
    @book.tags.should include(@fiction)
    @book.tags.should include(@english)    
  end
  
  # Get books from tags
  it "should be able to get books tagged with a tag" do
    @english.books.should have(1).thing
    @english.books.first.should == @book

    @fiction.books.should have(1).thing
    @fiction.books.first.should == @book
  end
  
  # Book Untagging
  it "should be able to untag a book" do
    @book.untag(@english)
    @book.tags.reload
    @book.tags.should_not include(@english)
    @book.tags.should include(@fiction)
    
    @english.posts.reload
    @english.posts.should be_empty
  end
    
  it "should provide a method for listing the books tagged by bob" do
    @bob.books.should be_empty
  end

  it "bob user should be able to tag a book as a tagger" do
    @scifi = Tag.build('scifi')
    @bob.tag(@book, :with => @scifi)
    
    @bob.books.reload
    @bob.books.should have(1).thing
    @bob.books.should include(@book)
    
    @scifi.books.should have(1).thing
    @scifi.books.should include(@book)
    
    @book.tags.reload
    @book.tags.should have(2).thing
    @book.tags.should include(@scifi) # tagged by bob
    @book.tags.should include(@fiction) # without taggers
  end
  
  it "User should be tagger" do
    User.should be_tagger
  end
  
  it "should be able to tag a book with the tags_list= helper" do
    @book.tags_list = ""
    @book.tags.reload
    @book.tags.should be_empty
    
    @book.tags_list = "orange, red"
    @book.tags.reload
    @book.tags.should have(2).things
    @book.tags.should include(Tag.build('orange'))
    @book.tags.should include(Tag.build('red'))    
  end
  
  it "should be able to tag a newly created object with tags_list=" do
    new_book = Book.new(:title => "Awesome world", :isbn => "1234567890124", :author => "Wonderful author")
    new_book.tags_list = "new, awesome, book"
    new_book.save
    
    new_book.reload
    new_book.tags.should have(3).things
    ['new', 'awesome', 'book'].each do |tag|
      new_book.tags.should include(Tag.build(tag))
    end
  end
end
