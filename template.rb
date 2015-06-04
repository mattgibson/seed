# This should leave us with a Rails 4 app ready for BDD with Rspec and Cucumber

db_username = ask("Postgres user:")
db_pass = ask("Postgres pass:")

gem 'pg'
gem 'haml-rails'

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
  gem 'faker'
  gem 'capybara-screenshot'
  gem 'site_prism'
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

create_file 'features/support/maintain_database.rb' do
<<-'FILE'
ActiveRecord::Migration.maintain_test_schema!
FILE
end

create_file 'features/support/paths.rb' do
<<-'FILE'
module NavigationHelpers

  def path_to(page_name)

    case page_name

    when 'home'
      root_path

    else
      path_components = page_name.split(/\s+/) # 'new teaching resource'
      model_name = path_components.dup
      model_name.shift if %W{show edit new destroy update create index}.include?(model_name.first) # 'teaching resource'

      model = instance_variable_get "@#{model_name.join('_')}" # '@teaching_resource'

      begin
        self.send(path_components.push('path').join('_').to_sym, model) # 'new_teaching_resource_path'
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path:\n" +
              "#{e.message}\n" +
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
FILE
end

create_file 'features/steps/general_steps.rb' do
<<-'FILE'
When(/^I visit the (.*) page$/) do |page_name|
  visit path_to page_name
end

Then(/^show me a screenshot/) do
  screenshot_and_open_image
end

Then(/^show me the page/) do
  save_and_open_page
end
FILE
end

create_file 'features/support/extra_env.rb' do
<<-'FILE'
require 'capybara/poltergeist'
require 'capybara-screenshot/cucumber'

World FactoryGirl::Syntax::Methods

Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
  DatabaseCleaner.strategy = :truncation
end

Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
  DatabaseCleaner.strategy = :transaction
end

Capybara.javascript_driver = :poltergeist
FILE
end

gsub_file 'spec/support/factory_girl.rb', 'end', "  config.include FactoryGirl::Syntax::Methods\nend"

gsub_file 'config/database.yml', 'default: &default', "default: &default\n  user: #{db_username}\n  pass: #{db_pass}"
rake 'db:create'
rake 'db:migrate'
rake 'db:create', env: 'test'
rake 'db:migrate', env: 'test'

after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
