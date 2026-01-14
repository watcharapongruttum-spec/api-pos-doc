# config/initializers/rswag_api.rb

if defined?(Rswag)
  Rswag::Api.configure do |c|
    c.swagger_root = Rails.root.to_s + '/swagger'
  end
end
