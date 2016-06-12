# This will leave us with a Rails 4 app ready for BDD with Rspec and Cucumber.

db_username = ask('Postgres user:')
db_pass = ask('Postgres pass:')

gem 'pg'
gem 'haml-rails'
gem 'react_on_rails'

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

# Get the templates for various files.
base_pathname = Pathname.new(File.join(__dir__, 'templates'))
template_files = Dir[File.join(__dir__, 'templates', '**', '*')].grep(/rb|json/)
template_files.each do |file|
  source_path = file
  dest_path = Pathname.new(file).relative_path_from(base_pathname)
  puts "copying from #{source_path} to #{dest_path}"
  copy_file source_path, dest_path
end

# Edit a few files to add stuff we need.
gsub_file 'spec/rails_helper.rb',
          /^end/,
          "  config.include FactoryGirl::Syntax::Methods\nend"

gsub_file 'spec/rails_helper.rb', /require 'rspec\/rails'/, <<-'INSERT'
require 'rspec/rails'
require 'webmock/rspec'
require 'support/vcr_setup'

VCR.configure do |c|
  c.configure_rspec_metadata!
end

INSERT

gsub_file 'config/database.yml',
          'default: &default',
          "default: &default\n  user: #{db_username}\n  pass: #{db_pass}"

application 'config.assets.enabled = false # Only use webpack for CSS and JS'

# Set up the databases.
rake 'db:create'
rake 'db:migrate'
rake 'db:create', env: 'test'
rake 'db:migrate', env: 'test'

# Initialise the project as a git repository.
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"

  generate 'react_on_rails:install --redux' # Will not run with uncommitted code
  run 'npm install'

  git add: '.'
  git commit: "-a -m 'Add react_on_rails'"
end

# Using the -J option from the command line means that the app layout does not
# include the JS at all. This skips JQuery and sprockets as we want, but does
# not include all the webpack stuff we want.
gsub_file 'app/views/layouts/application.html.erb',
          '<%= csrf_meta_tags %>',
          "<%= csrf_meta_tags %>\n"\
          "  <%= javascript_include_tag 'webpack-bundle' %>\n"\
          "  <% if Rails.env.development? %>\n"\
          "    <script src=\" http://<%= request.host %>:3808/webpack-dev-server.js\"></script>\n"\
          "  <% end %>\n"

append_to_file 'config/initializers/assets.rb',
               'Rails.application.config.assets.precompile += %w( webpack-bundle.js )'
remove_file 'app/assets/javascripts/application.js'

puts 'OK. All done.'
puts 'now try it out with:'
puts "\n"
puts 'cd yourapp'
puts 'npm run rails-server'
puts "\n"
puts 'Then visit http://localhost:3000/hello_world'
