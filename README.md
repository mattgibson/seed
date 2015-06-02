## Usage

Make sure you have postgres installed locally. You will be prompted to provide
the username and password for it, so ensure you have these details to hand.

Database details will be added to the default section of `database.yml`, so
the tests will run.

```
cd parent/directory
gem install rails
git clone https://github.com/mattgibson/seed
rails new your_app_name -T -d postgresql -m 'seed/template.rb'
```

## What's installed

* Rails at the latest version
* Cucumber
* Rspec
* Factory girl

Databases are created. Files are committed to git in their final state.