# README

## Project creation
### Install Node and Yarn
```bash
brew install node
npm install -g yarn
```

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

### Configure DB
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

### Configure Elastic
Add Elastic dependencies to `Gemfile`:
```gemfile
# elastic search
gem 'elasticsearch-model', '~> 7.2', '>= 7.2.1'
gem 'elasticsearch-rails', '~> 7.2', '>= 7.2.1'
```
Install new dependencies:
```bash
bundle install
```
Create file `config/initializers/elasticsearch.rb` with content:
```ruby
# Connect to specific Elasticsearch cluster
ELASTICSEARCH_URL = ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'

Elasticsearch::Model.client = Elasticsearch::Client.new host: ELASTICSEARCH_URL
```
Add Elastic to `docker-compose.yaml`
```diff
version: '3.6'

services:
  db:
    ...
+  es:
+    image: elasticsearch:7.17.9
+    environment:
+      - xpack.security.enabled=false
+      - discovery.type=single-node
+    volumes:
+      - esdata:/usr/share/elasticsearch/data
+    ports:
+      - 9200:9200
+      - 9300:9300

volumes:
  ...
+  esdata:
+    driver: local
```
Create concern for elastic models:
```ruby
# app/models/concerns/searchable.rb

module Searchable
    extend ActiveSupport::Concern
  
    included do
        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks

        # index name will depend on the environment
        index_name [Rails.env, model_name.collection.underscore].join('_')

        # mapping do
        #     # mapping definition goes here
        # end

        # def self.search(query)
        #     # build and run search
        # end
    end
end
```
Update `Post` model
```ruby
class Post < ApplicationRecord
    include Searchable
end
```
Restart applicacation with `bin/dev`, create some Post entries with app and check that index created in elastic (http://localhost:9200/development_posts)
