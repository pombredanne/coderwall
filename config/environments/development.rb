Coderwall::Application.configure do
  config.eager_load = true

  require 'sidekiq/testing/inline'

  config.action_controller.perform_caching      = false
  config.action_dispatch.best_standards_support = :builtin
  config.active_support.deprecation             = :log
  config.assets.compile                         = true
  config.assets.compress                        = false
  config.assets.debug                           = false
  config.cache_classes                          = false
  config.consider_all_requests_local            = true
  config.host                                   = 'localhost:3000'
  config.serve_static_assets                    = true
  config.whiny_nils                             = true

  # Mailer settings
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method       = :file
  config.action_mailer.file_settings         = { location: "#{Rails.root}/tmp/mailers" }
  config.action_mailer.asset_host            = "http://#{config.host}"

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Mock account credentials
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:linkedin] = OmniAuth::AuthHash.new({
    :provider => 'linkedin',
    :uid => 'linkedin12345',
    :info => {:nickname => 'linkedinuser'},
    :credentials => {
      :token => 'linkedin1',
      :secret => 'secret'}})
  OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
    :provider => 'twitter', 
    :uid => 'twitter123545', 
    :info => {:nickname => 'twitteruser'}, 
    :credentials => {
      :token => 'twitter1', 
      :secret => 'secret'}})
  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
    :provider => 'github', 
    :uid => 'github123545', 
    :info => {:nickname => 'githubuser'}, 
    :credentials => {
      :token => 'github1', 
      :secret => 'secret'}})
end
