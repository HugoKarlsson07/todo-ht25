require 'sqlite3'
require 'bcrypt'

db = SQLite3::Database.new("todos.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS todos')
  db.execute('DROP TABLE IF EXISTS categories')
  db.execute('DROP TABLE IF EXISTS users')
end

def create_tables(db)
  db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT, status BOOL DEFAULT false, 
              id_category INTEGER,
              user_id INTEGER NOT NULL,
              FOREIGN KEY (id_category) REFERENCES categories(id),
              FOREIGN KEY (user_id) REFERENCES users(id))')
  db.execute('CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, category_name TEXT NOT NULL)')
  db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_name TEXT NOT NULL, pwd_digest TEXT NOT NULL )')
end

def populate_tables(db)
  # categories first
  db.execute('INSERT INTO categories (category_name) VALUES ("köpa")')
  db.execute('INSERT INTO categories (category_name) VALUES ("Om tid finns")')
  db.execute('INSERT INTO categories (category_name) VALUES ("Publik")')
  db.execute('INSERT INTO categories (category_name) VALUES ("private")')

  # users
  pass_digest = BCrypt::Password.create("roblox")
  db.execute('INSERT INTO users (user_name, pwd_digest) VALUES (?, ?)',
             ["victor", pass_digest])
  user_id = db.last_insert_row_id

  # then todos
  db.execute('INSERT INTO todos (name, description, status, id_category, user_id)
              VALUES ("Köp mjölk", "3 liter mellanmjölk, eko", false, 4, ?)', [user_id])
  db.execute('INSERT INTO todos (name, description, status, id_category, user_id)
              VALUES ("Köp julgran", "En rödgran", false, 4, ?)', [user_id])
  db.execute('INSERT INTO todos (name, description, status, id_category, user_id)
              VALUES ("Pynta gran", "Glöm inte lamporna i granen och tomten", false, 4, ?)', [user_id])
end


seed!(db)