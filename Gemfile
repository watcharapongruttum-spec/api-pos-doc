source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby '3.2.2'
ruby "~> 3.3.0"


# Rails 6.1.x
gem 'rails', github: 'rails/rails', branch: '6-1-stable'


# Database
gem 'pg', '~> 1.6'

# Web server
gem 'puma', '>= 5.0'

# Authentication & JWT
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'

# CORS
gem 'rack-cors'

# PDF
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'prawn'
gem 'prawn-table'

# Environment variables
gem 'dotenv-rails'

# Testing
# gem 'rswag'
# gem 'rswag-api'
# gem 'rswag-ui'
# gem 'rswag-specs'
# gem 'rspec-rails', '~> 6.0'

gem 'rswag-api'
gem 'rswag-ui'

gem 'rswag'












# Timezone
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Boot optimization
gem 'bootsnap', require: false

group :development, :test do
  gem 'byebug'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'web-console'
end
