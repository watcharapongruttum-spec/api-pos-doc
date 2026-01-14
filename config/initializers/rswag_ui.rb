if defined?(Rswag::Ui)
  Rswag::Ui.configure do |c|
    c.openapi_endpoint '/swagger/v1/swagger.yaml', 'POS API v1'
  end
end
