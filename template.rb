# This should leave us with a Rails 4 app ready for BDD with Rspec and Cucumber

db_username = ask('Postgres user:')
db_pass = ask('Postgres pass:')

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
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara-screenshot'
  gem 'site_prism'
  gem 'webmock'
  gem 'vcr'
end

run 'bundle install'

generate 'cucumber:install'
generate 'rspec:install'

run 'bundle exec spring binstubs'

get 'https://raw.github.com/mattgibson/seed/master/templates/spec/smoke_spec.rb', 'spec/smoke_spec.rb'

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

create_file 'features/step_definitions/general_steps.rb' do
<<-'FILE'
When(/^I (?:visit|am on) the (.*) page$/) do |page_name|
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

gsub_file 'spec/rails_helper.rb', /^end/, "  config.include FactoryGirl::Syntax::Methods\nend"

gsub_file 'spec/rails_helper.rb', /require 'rspec\/rails'/, <<-'INSERT'
require 'rspec/rails'
require 'webmock/rspec'
require 'support/vcr_setup'

VCR.configure do |c|
  c.configure_rspec_metadata!
end

INSERT

create_file 'features/support/webmock.rb' do
<<-'FILE'
require 'webmock/cucumber'
FILE
end

create_file 'spec/support/vcr_setup.rb' do
<<-'FILE'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end
FILE
end

create_file 'features/support/vcr.rb' do
<<-'FILE'
require File.expand_path("../../../spec/support/vcr_setup", __FILE__)

VCR.cucumber_tags do |t|
  t.tag  '@vcr', :use_scenario_name => true
  t.tags '@vcr_new_episodes', :record => :new_episodes
end
FILE
end


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
