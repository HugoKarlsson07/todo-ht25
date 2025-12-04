require 'sqlite3'

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
end

def create_tables(db)
  db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT, status BOOL DEFAULT false, id_category INTEGER,
              FOREIGN KEY (id_category) REFERENCES categories(id))')
  db.execute('CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)')
end

def populate_tables(db)
  # Lägg till todos
  db.execute('INSERT INTO todos (name, description, status) VALUES ("Köp mjölk", "3 liter mellanmjölk, eko",false)')
  db.execute('INSERT INTO todos (name, description, status) VALUES ("Köp julgran", "En rödgran", false)')
  db.execute('INSERT INTO todos (name, description, status) VALUES ("Pynta gran", "Glöm inte lamporna i granen och tomten",false)')
  # Lägg till kategorier
  db.execute('INSERT INTO categories (name) VALUES ("köpa")')
  db.execute('INSERT INTO categories (name) VALUES ("Om tid finns")')
  db.execute('INSERT INTO categories (name) VALUES ("Publik")')
  db.execute('INSERT INTO categories (name) VALUES ("private")')
end

seed!(db)