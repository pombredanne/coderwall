require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
I18n.config.enforce_available_locales = false

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Coderwall
  class Application < Rails::Application

    config.autoload_paths += Dir[Rails.root.join('app', 'models',      'concerns', '**/' )]
    config.autoload_paths += Dir[Rails.root.join('app', 'controllers', 'concerns', '**/' )]
    config.autoload_paths += Dir[Rails.root.join('lib', '**/'                            )]

    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    config.encoding = 'utf-8'

    config.filter_parameters += [:password]

    config.assets.js_compressor = :uglifier

    config.after_initialize do
      if ENV['ENABLE_HIRB'] && %w{development test}.include?(Rails.env)
        Hirb.enable
      end
    end

    config.exceptions_app = self.routes
  end
end

ENABLE_TRACKING = !ENV['MIXPANEL_TOKEN'].blank?

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  %(<span class="field_with_errors">#{html_tag}</span>).html_safe
}
