class User < ApplicationRecord
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :receipts, dependent: :destroy

  after_create :create_cart_for_user

  validates :role, inclusion: { in: %w(admin user), message: "%{value} is not a valid role" }
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  # 🔹 search scope (แทน search_sql)
  scope :search, ->(keyword) {
    if keyword.present?
      where(
        "username ILIKE :q OR name ILIKE :q",
        q: "%#{keyword}%"
      )
    else
      all
    end
  }

  # 🔹 format json สำหรับ response
  def self.respond_to_json_user(users)
    users.map do |user|
      {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role
      }
    end
  end

  private

  def create_cart_for_user
    create_cart!(
      total_summary: 0,
      total_amount: 0,
      status: "active"
    )
  end
end
