puts "🌱 Seeding data..."

# ======================
# Users
# ======================
admin = User.find_or_create_by!(username: "admin") do |u|
  u.name = "Administrator"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "admin"
end

user = User.find_or_create_by!(username: "user") do |u|
  u.name = "Default User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "user"
end

puts "✅ Users seeded"

# ======================
# Categories
# ======================
food = Category.find_or_create_by!(name: "Food")
drink = Category.find_or_create_by!(name: "Drink")

puts "✅ Categories seeded"

# ======================
# SKU Masters (Products)
# ======================
SkuMaster.find_or_create_by!(name: "Fried Rice") do |s|
  s.category = food
  s.amount = 100
  s.price = 50
end

SkuMaster.find_or_create_by!(name: "Noodles") do |s|
  s.category = food
  s.amount = 80
  s.price = 45
end

SkuMaster.find_or_create_by!(name: "Water") do |s|
  s.category = drink
  s.amount = 200
  s.price = 10
end

SkuMaster.find_or_create_by!(name: "Cola") do |s|
  s.category = drink
  s.amount = 150
  s.price = 20
end

puts "✅ Products seeded"

# ======================
# Cart (example)
# ======================
cart = Cart.find_or_create_by!(user: user, status: "active") do |c|
  c.total_amount = 0
  c.total_summary = 0
end

puts "✅ Cart seeded"

puts "🌱 Seeding completed successfully!"



