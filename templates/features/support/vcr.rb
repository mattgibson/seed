require File.expand_path("../../../spec/support/vcr_setup", __FILE__)

VCR.cucumber_tags do |t|
  t.tag '@vcr', :use_scenario_name => true
  t.tags '@vcr_new_episodes', :record => :new_episodes
end