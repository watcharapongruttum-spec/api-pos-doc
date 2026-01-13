# scripts/generate_swagger.rb
require 'rails'
require 'active_support/all'
require_relative '../config/environment'
require 'yaml'

SWAGGER_FILE = Rails.root.join('swagger', 'v1', 'swagger.yaml')

# เริ่มต้นโครงสร้าง Swagger
swagger = {
  'openapi' => '3.0.3',
  'info' => {
    'title' => 'POS API',
    'version' => 'v1'
  },
  'servers' => [{ 'url' => 'http://localhost:3000' }],
  'components' => {
    'securitySchemes' => {
      'bearerAuth' => { 'type' => 'http', 'scheme' => 'bearer', 'bearerFormat' => 'JWT' }
    }
  },
  'security' => [{ 'bearerAuth' => [] }],
  'tags' => [],
  'paths' => {}
}

# รายการ prefix / keyword ของ route ที่ต้องการตัด
EXCLUDE_PATTERNS = [
  'rails/info',
  'rails/mailers',
  'rails/conductor',
  'rails/active_storage',
  'rails/action_mailbox',
  'welcome',
  'proxy',
  'disk',
  'direct_uploads',
  'redirect',
  'sources',
  'reroutes',
  'inbound_emails',
  'info',
  'mailers',
    'welcome'
].freeze

Rails.application.routes.routes.each do |route|
  # skip route ที่เป็น internal
  path = route.path.spec.to_s.gsub('(.:format)', '')
  next if EXCLUDE_PATTERNS.any? { |p| path.downcase.include?(p) }

  controller = route.defaults[:controller]
  action = route.defaults[:action]
  next if controller.blank? || action.blank?

  tag_name = controller.split('/').last.camelize
  swagger['tags'] << { 'name' => tag_name, 'description' => "#{tag_name} operations" } unless swagger['tags'].any? { |t| t['name'] == tag_name }

  # กำหนด method
  method = route.verb.to_s.downcase
  method = 'get' if method.blank? || method == 'any'

  swagger['paths'][path] ||= {}
  swagger['paths'][path][method] ||= {
    'tags' => [tag_name],
    'summary' => "#{action} action",
    'responses' => { '200' => { 'description' => 'Success' } }
  }

  # add path param ถ้าเป็น :id
  if path.include?(':id')
    swagger['paths'][path][method]['parameters'] ||= []
    swagger['paths'][path][method]['parameters'] << {
      'name' => 'id',
      'in' => 'path',
      'required' => true,
      'schema' => { 'type' => 'integer' }
    }
  end
end

# แปลง key เป็น string ทั้งหมดเพื่อให้ Psych.safe_load อ่านได้
def stringify_keys(obj)
  case obj
  when Hash
    obj.each_with_object({}) { |(k,v), h| h[k.to_s] = stringify_keys(v) }
  when Array
    obj.map { |v| stringify_keys(v) }
  else
    obj
  end
end

File.write(SWAGGER_FILE, stringify_keys(swagger).to_yaml)
puts "Swagger YAML generated at #{SWAGGER_FILE}"
