## Usage

Make sure you have postgres installed locally. You will be prompted to provide
the username and password for it, so ensure you have these details to hand.

Database details will be added to the default section of `database.yml`, so
the tests will run.

```
cd parent/directory
gem install rails
rails new your_app_name -T -d postgresql -m 'https://raw.githubusercontent.com/mattgibson/seed/master/template.rb'
```

## What's installed

* Rails at the latest version
* Cucumber
* Rspec
* Factory girl

Databases are created. Files are committed to git in their final state.

## Other requirements

To create and run JavaScript Cucumber tests, tag the scenarios with 
`@javascript` and make sure you have PhantomJS installed:

OSX: `brew install phantomjs`

## Test helpers

See the `/features/support/general_steps.rb` file for handy Cucumber steps.

If you have defined a model as `@model_name` in a previous step, then using
`When I visit the edit model name page` will automatically follow the correct 
path.

Add extra non-standard path names to `/features/support/paths.rb`

## VCR 

Use the @vcr tag on Cucumber features to cause a new casette to be created
as `/fixtures/vcr_cassettes/feature_name/sceanrio_name.yml`