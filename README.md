# README

## Project creation
### Generate app 
To create rails app with Bootstrap and without test support: 
```bash
rails new turbotest -c bootstrap -T
```

### Scuffold Post
```bash
bin/rails g scaffold post title:string content:text
```
Migrate db: 
```bash
bin/rails db:migrate
```

### Configure RSpec
Add to Gemfile:
```gemfile
gem "rspec-rails"
gem "factory_bot_rails"
gem "faker"
```
Run:
```bash
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

## Configure DB
Create `docker-compose.yaml` with following content:
```yaml
version: '3.6'

services:
  db:
    image: postgres:14.7-alpine
    restart: always
    volumes:
      - pgdata:/var/lib/postgresql/data/
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - 5432:5432

volumes:
  pgdata:
```
Update `config/database.yaml` with following content:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch("DB_HOST") { "localhost" } %>
  port: 5432
  username: postgres
  password: postgres
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: <%= ENV.fetch("DB_NAME") { "postgres" } %>
  
# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: postgres_test
  

production:
  <<: *default
  database: postgres
```
Replace in `Gemfile`:
```diff
- gem "sqlite3", "~> 1.4"
+ gem "pg", "~> 1.4"
```
Install dependency:
```bash
brew install postgresql
bundle install
# migrate db again, because we changed db
bin/rails db:migrate
```


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
