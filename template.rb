# This should leave us with a Rails 4 app ready for BDD with Rspec and Cucumber

db_username = ask("Postgres user:")
db_pass = ask("Postgres pass:")

gem 'pg'

gem_group :develpment, :test do
  gem 'rspec-rails'
end

gem_group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'capybara-screenshot'
end

run 'bundle install'


generate 'cucumber:install'
generate 'rspec:install'

run 'bundle exec spring binstubs'

create_file 'spec/smoke_spec.rb' do
<<-'FILE'
require 'rails_helper'

describe 'smoke test' do
  it 'works' do
    expect(true).to be_truthy
  end
end
FILE
end

gsub_file 'config/database.yml', 'default: &default', "default: &default\n  user: #{db_username}\n  pass: #{db_pass}"
rake 'db:create'
rake 'db:migrate'

git :init
git add: '.'
git commit: "-a -m 'Initial commit'"
