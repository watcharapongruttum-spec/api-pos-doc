# scripts/generate_swagger.rb
require 'rails'
require 'active_support/all'
require_relative '../config/environment'
require 'yaml'
require 'set'

SWAGGER_FILE = Rails.root.join('public', 'swagger', 'v1', 'swagger.yaml')

swagger = {
  'openapi' => '3.0.3',
  'info' => {
    'title' => 'POS API',
    'version' => 'v1'
  },
  'servers' => [{ 'url' => 'http://localhost:3000' }],
  'tags' => [
    { 'name' => 'Auth', 'description' => 'Authentication' }
  ],
  'components' => {
    'securitySchemes' => {
      'bearerAuth' => {
        'type' => 'http',
        'scheme' => 'bearer',
        'bearerFormat' => 'JWT'
      }
    },
    'schemas' => {}
  },
  'security' => [{ 'bearerAuth' => [] }],
  'paths' => {}
}

EXCLUDE_PATTERNS = %w[
  rails/info rails/mailers rails/conductor
  rails/active_storage rails/action_mailbox
  proxy disk direct_uploads redirect
  inbound_emails mailers
].freeze

swagger_tags = Set.new(['Auth'])

Rails.application.routes.routes.each do |route|
  path = route.path.spec.to_s.gsub('(.:format)', '')
  next if EXCLUDE_PATTERNS.any? { |p| path.downcase.include?(p) }

  controller = route.defaults[:controller]
  action     = route.defaults[:action]
  next if controller.blank? || action.blank?

  method = route.verb.to_s.downcase
  method = 'get' if method.blank? || method == 'any'

  swagger_path = path.gsub(':id', '{id}')
  swagger['paths'][swagger_path] ||= {}

  # =========================
  # 🔐 LOGIN
  # =========================
  if swagger_path.match?(/\/login/)
    swagger['components']['schemas']['LoginRequest'] ||= {
      'type' => 'object',
      'properties' => {
        'username' => { 'type' => 'string' },
        'password' => { 'type' => 'string' }
      },
      'required' => %w[username password]
    }

    swagger['paths'][swagger_path][method] = {
      'tags' => ['Auth'],
      'summary' => 'Login',
      'security' => [],
      'requestBody' => {
        'required' => true,
        'content' => {
          'application/json' => {
            'schema' => { '$ref' => '#/components/schemas/LoginRequest' },
            'example' => {
              'username' => 'admin',
              'password' => '123456'
            }
          }
        }
      },
      'responses' => {
        '200' => { 'description' => 'Login success' }
      }
    }
    next
  end

  tag_name = controller.split('/').last.camelize
  unless swagger_tags.include?(tag_name)
    swagger['tags'] << { 'name' => tag_name }
    swagger_tags << tag_name
  end

  swagger['paths'][swagger_path][method] ||= {
    'tags' => [tag_name],
    'summary' => action,
    'responses' => {
      '200' => { 'description' => 'Success' }
    }
  }

  next unless %w[post put patch].include?(method)

  # =========================
  # 🧑‍💻 USERS CREATE
  # =========================
  if controller == 'users' && method == 'post'
    swagger['components']['schemas']['UserCreateRequest'] ||= {
      'type' => 'object',
      'properties' => {
        'user' => {
          'type' => 'object',
          'properties' => {
            'username' => { 'type' => 'string' },
            'password' => { 'type' => 'string' },
            'name'     => { 'type' => 'string' },
            'role'     => { 'type' => 'string' }
          },
          'required' => %w[username password name role]
        }
      },
      'required' => ['user']
    }

    swagger['paths'][swagger_path][method]['requestBody'] = {
      'required' => true,
      'content' => {
        'application/json' => {
          'schema' => { '$ref' => '#/components/schemas/UserCreateRequest' },
          'example' => {
            'user' => {
              'username' => 'example',
              'password' => '123456',
              'name' => 'example',
              'role' => 'user'
            }
          }
        }
      }
    }
    next
  end

  # =========================
  # 📦 ActiveRecord → Schema
  # =========================
  begin
    model = controller.singularize.camelize.constantize
  rescue NameError
    next
  end
  next unless model < ActiveRecord::Base

  schema_name = model.name
  unless swagger['components']['schemas'][schema_name]
    properties = {}
    required = []

    model.columns.each do |col|
      next if %w[id created_at updated_at].include?(col.name)

      required << col.name unless col.null
      properties[col.name] =
        case col.type
        when :integer, :bigint
          { 'type' => 'integer' }
        when :float
          { 'type' => 'number', 'format' => 'float' }
        when :decimal
          { 'type' => 'number', 'format' => 'decimal' }
        when :boolean
          { 'type' => 'boolean' }
        else
          { 'type' => 'string' }
        end
    end

    swagger['components']['schemas'][schema_name] = {
      'type' => 'object',
      'properties' => properties,
      'required' => required
    }
  end

  swagger['paths'][swagger_path][method]['requestBody'] = {
    'required' => true,
    'content' => {
      'application/json' => {
        'schema' => {
          'type' => 'object',
          'properties' => {
            controller.singularize => {
              '$ref' => "#/components/schemas/#{schema_name}"
            }
          },
          'required' => [controller.singularize]
        }
      }
    }
  }
end

File.write(SWAGGER_FILE, swagger.to_yaml)
puts "✅ Swagger YAML generated with schemas at #{SWAGGER_FILE}"
