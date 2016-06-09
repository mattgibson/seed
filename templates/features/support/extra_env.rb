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
