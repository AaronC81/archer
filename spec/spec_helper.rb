require 'capybara'
require 'capybara/rspec'
require 'capybara/dsl'
require 'selenium/webdriver'
require 'rack'

# A simple Rack app to host a static site, respecting `index.html` in nested directories.
# 
# `Rack::Static`, `Rack::File(s)` and `Rack::Directory` all can't handle nested `index.html` files,
# so this exists as a wrapper around `Rack::Files` to resolve them manually.
#
# Based on https://nts.strzibny.name/how-to-test-static-sites-with-rspec-capybara-and-webkit/
class StaticApp
  attr_reader :root, :server

  def initialize(root)
    @root = root
    @server = Rack::Files.new(root)
  end

  def call(env)
    path = env['PATH_INFO']

    # Mappings:
    #   /             => /index.html
    #   /target/X86/  => /target/X86/index.html
    #   /target/X86   => /target/X86/index.html
    
    if path == '/'
      env['PATH_INFO'] = '/index.html'
    elsif !file?(path)
      path += '/' unless path.end_with?('/')
      if file?(path + 'index.html')
        env['PATH_INFO'] = path + 'index.html'
      end
    end

    server.call(env)
  end

  def file?(path)
    File.file?(File.join(root, path))
  end
end

# Get Capybara to host our static site for us
Capybara.app = Rack::Builder.new do
  run StaticApp.new(File.join(__dir__, '..', 'build'))
end.to_app

# Use Selenium as a JavaScript-compatible driver engine
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options: Selenium::WebDriver::Firefox::Options.new.tap do |opts|
      opts.args << '--headless' if ENV['CAPYBARA_HEADLESS']
    end
  )
end
Capybara.default_driver = :selenium


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
