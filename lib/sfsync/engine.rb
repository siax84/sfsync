module Sfsync
  class Engine < ::Rails::Engine
  require 'rubygems'
  require 'restforce'    
    isolate_namespace Sfsync
    Restforce.configure do |config|
      config.username = ''
      config.password = ''
      config.security_token = ''
      config.client_id = ''
      config.client_secret  = ''
      config.api_version = "32.0"
    end
  end
end
