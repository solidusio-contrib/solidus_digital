source 'https://rubygems.org'

gem 'solidus', '~> 2.0.2'
gemspec

group :test do
  gem "pry-byebug"
  gem "rails-controller-testing"

  if RUBY_PLATFORM.downcase.include? "darwin"
    gem 'guard-rspec'
    gem 'rb-fsevent'
    gem 'growl'
  end
end
