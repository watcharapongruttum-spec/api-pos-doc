source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', github: 'rails/rails', branch: '6-1-stable'

# Database
gem 'pg', '~> 1.6'

# Web server
gem 'puma', '>= 5.0'

# Auth
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'

# CORS
gem 'rack-cors'

# PDF

gem 'prawn'
gem 'prawn-table'

# Boot optimization
gem 'bootsnap', require: false

# Timezone
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'dotenv-rails'
  gem 'byebug'
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # Swagger / Rswag (dev only)
  gem 'rswag'
  gem 'rswag-api'
  gem 'rswag-ui'
  gem 'wicked_pdf'
  gem 'wkhtmltopdf-binary'

end

group :development do
  gem 'web-console'
end
