$stdout.sync = true

require "bundler/setup"
Bundler.require

# Silence Rack Logger
class Rack::CommonLogger
  def call(env)
    @app.call(env)
  end
end

$:.unshift File.expand_path("../web", __FILE__)
require "toolbelt"
run Toolbelt
