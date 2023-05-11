# README

## Project creation
### Generate app
Generated: `rails new turbotest -c bootstrap -T`
### Configure RSpec
Add to Gemfile:
```
gem "rspec-rails"
gem "factory_bot_rails"
gem "faker"
```
Run:
```
bundle install
rails g rspec:install
```
Configure FactoryBot (create file with following content):
```ruby
# filenama: spec/support/factory_bot.rb
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
```
Configure browser support (create file with following content):
```ruby
# filename: spec/support/chrome.rb

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["SHOW_BROWSER"] == "true"
      driven_by :selenium_chrome
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
    end
  end
end
```
Update `spec/rails_helper.rb` content, add this:
```ruby
require_relative 'support/factory_bot'
require_relative 'support/chrome'
```
Create a factory for model:
```ruby
# spec/factories.rb

FactoryBot.define do
  factory(:post) do
    title { Faker::Book.title }
    content { Faker::Lorem.paragraph_by_chars }
  end
end
```
Create first spec:
```ruby
# filename spec/models/post_spec.rb

require "rails_helper"

RSpec.describe Post, type: :model do
    describe "working with Post" do
        it "can be created" do
            post = create(:post)
            expect(Post.where(id: post.id).exists?).to be true
        end
    end
end
```
Run `rspec` in console to test everything is working

## Stuff
This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
