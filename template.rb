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


%w(
spec/smoke_spec.rb
features/support/maintain_database.rb
features/support/paths.rb
features/step_definitions/general_steps.rb
features/support/extra_env.rb
features/support/webmock.rb
spec/support/vcr_setup.rb
features/support/vcr.rb
).each do |file|
  get "https://raw.github.com/mattgibson/seed/master/templates/#{file}", file
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
