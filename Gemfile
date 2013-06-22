# coding UTF-8

source 'https://rubygems.org'

gem 'jbundler'
gem 'jruby-openssl'
gem 'nesty'
gem 'rails', '~> 3.2.13'
gem 'roar-rails'

# Gems used only for assets and not required in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'haml-rails'
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'therubyrhino'
  gem 'uglifier'
  gem 'zurb-foundation'
end

group :development do
  gem 'kss-rails'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'teabag'
end

group :test do
  gem 'webmock', require: 'webmock/rspec'
end
