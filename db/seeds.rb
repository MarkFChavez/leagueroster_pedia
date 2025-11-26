# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding sample data..."

# Create sample teams
t1 = Team.find_or_create_by!(name: "T1") do |team|
  team.short_name = "T1"
  team.region = "Korea"
  team.logo_url = "T1logo_square.png"
  team.website = "https://t1.gg"
  team.is_disbanded = false
  team.last_synced_at = Time.current
end

hle = Team.find_or_create_by!(name: "Hanwha Life Esports") do |team|
  team.short_name = "HLE"
  team.region = "Korea"
  team.logo_url = "Hanwha Life Esportslogo square.png"
  team.is_disbanded = false
  team.last_synced_at = Time.current
end

g2 = Team.find_or_create_by!(name: "G2 Esports") do |team|
  team.short_name = "G2"
  team.region = "Europe"
  team.logo_url = "G2 Esportslogo square.png"
  team.website = "https://g2esports.com"
  team.is_disbanded = false
  team.last_synced_at = Time.current
end

# Create sample players for T1
Player.find_or_create_by!(team: t1, ign: "Zeus") do |player|
  player.real_name = "Choi Woo-je"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Top"
  player.age = 21
  player.is_current = true
  player.date_joined = Date.new(2022, 1, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: t1, ign: "Oner") do |player|
  player.real_name = "Moon Hyeon-jun"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Jungle"
  player.age = 22
  player.is_current = true
  player.date_joined = Date.new(2021, 1, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: t1, ign: "Faker") do |player|
  player.real_name = "Lee Sang-hyeok"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Mid"
  player.age = 28
  player.is_current = true
  player.date_joined = Date.new(2013, 2, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: t1, ign: "Gumayusi") do |player|
  player.real_name = "Lee Min-hyeong"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Bot"
  player.age = 22
  player.is_current = true
  player.date_joined = Date.new(2021, 1, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: t1, ign: "Keria") do |player|
  player.real_name = "Ryu Min-seok"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Support"
  player.age = 22
  player.is_current = true
  player.date_joined = Date.new(2021, 1, 1)
  player.last_synced_at = Time.current
end

# Create sample players for HLE
Player.find_or_create_by!(team: hle, ign: "Doran") do |player|
  player.real_name = "Choi Hyeon-joon"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Top"
  player.age = 23
  player.is_current = true
  player.date_joined = Date.new(2024, 1, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: hle, ign: "Peanut") do |player|
  player.real_name = "Han Wang-ho"
  player.country = "South Korea"
  player.nationality = "South Korea"
  player.role = "Jungle"
  player.age = 26
  player.is_current = true
  player.date_joined = Date.new(2023, 1, 1)
  player.last_synced_at = Time.current
end

# Create sample players for G2
Player.find_or_create_by!(team: g2, ign: "Broken Blade") do |player|
  player.real_name = "Sergen Çelik"
  player.country = "Germany"
  player.nationality = "Turkey"
  player.role = "Top"
  player.age = 24
  player.is_current = true
  player.date_joined = Date.new(2023, 11, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: g2, ign: "Yike") do |player|
  player.real_name = "Martin Sundelin"
  player.country = "Sweden"
  player.nationality = "Sweden"
  player.role = "Jungle"
  player.age = 21
  player.is_current = true
  player.date_joined = Date.new(2023, 11, 1)
  player.last_synced_at = Time.current
end

Player.find_or_create_by!(team: g2, ign: "Caps") do |player|
  player.real_name = "Rasmus Winther"
  player.country = "Denmark"
  player.nationality = "Denmark"
  player.role = "Mid"
  player.age = 24
  player.is_current = true
  player.date_joined = Date.new(2018, 11, 1)
  player.last_synced_at = Time.current
end

puts "Seed data created successfully!"
puts "Teams: #{Team.count}"
puts "Players: #{Player.count}"
