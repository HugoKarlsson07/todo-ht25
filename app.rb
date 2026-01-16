require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

before do
  public_paths = ['/login', '/user', '/error']

  return if public_paths.include?(request.path_info)
  return if request.path_info =~ %r{^/todos/\d+/edit$}

  redirect('/login') unless session[:user_id]
end


get('/login') do
  slim(:login)
end

get('/user') do
  slim(:register)
end

get('/welcome') do
  slim(:welcome)
end

get('/error') do
  slim(:error)
end

get('/logout') do
  session.clear
  redirect('/login')
end

post('/login') do
  user = params["user"]
  pwd  = params["pwd"]

  db = SQLite3::Database.new('db/todos.db')
  db.results_as_hash = true

  result = db.execute(
    "SELECT id, pwd_digest FROM users WHERE user_name = ?",
    [user]
  )

  redirect('/error') if result.empty?

  user_id    = result.first["id"]
  pwd_digest = result.first["pwd_digest"]

  if BCrypt::Password.new(pwd_digest) == pwd
    session[:user_id] = user_id
    redirect('/welcome')
  else
    redirect('/error')
  end
end

post('/user') do
  user = params["user"]
  pwd  = params["pwd"]
  pwd_confirm = params["pwd_confirm"]

  db = SQLite3::Database.new('db/todos.db')
  db.results_as_hash = true

  result = db.execute(
    "SELECT id FROM users WHERE user_name = ?",
    [user]
  )

  redirect '/login' unless result.empty?
  redirect '/error' unless pwd == pwd_confirm

  pwd_digest = BCrypt::Password.create(pwd)

  db.execute(
    "INSERT INTO users (user_name, pwd_digest) VALUES (?, ?)",
    [user, pwd_digest]
  )

  redirect('/welcome')
end









#ta bort 
post('/todos/:id/delete') do
    #hämtar todo
    id = params[:id].to_i
    #gör en koppling till databasen
    db = SQLite3::Database.new("db/todos.db")

    db.execute("DELETE FROM todos WHERE id=? AND user_id=?",[id, session[:user_id]])

    redirect('/todos')
end

#skappar todo
post('/todo') do
  new_todo = params[:new_todo] # Hämta datan ifrån formuläret
  description = params[:description].to_s 
  category_name = params[:category_name]


  db = SQLite3::Database.new('db/todos.db') # koppling till databasen
  db.execute("INSERT INTO todos (name, description, id_category, user_id) VALUES (?,?,?,?)",[new_todo,description,category_name, session[:user_id]])

  redirect('/todos') # Hoppa till routen som visar upp alla todos
end
#ändra
post('/todos/:id/update') do
  id = params[:id].to_i
  description = params[:description]
  name = params[:name]
  category_name = params[:category_name]

  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET name=?,description=?,id_category=? WHERE id=? AND user_id=?",[name,description,category_name,id, session[:user_id]])
   
  redirect('/todos')
end

post('/todos/:id/klar') do
  id = params[:id].to_i
  status = 1
  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET status=? WHERE id=? AND user_id=?",[status,id, session[:user_id]])
  redirect('/todos')
end  

post('/todos/:id/ice') do
  id = params[:id].to_i
  status = 0
  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET status=? WHERE id=? AND user_id=?",[status,id, session[:user_id]])
  redirect('/todos')
end


get('/todos/:id/edit') do
  db = SQLite3::Database.new("db/todos.db")
  db.results_as_hash = true
  id = params[:id].to_i
  
  
  @special_todo = db.execute("SELECT * FROM todos WHERE id = ? AND user_id = ?", [id, session[:user_id]]).first
  @data_categories = db.execute("SELECT * FROM categories")
  p @special_todo
  slim(:edit)
end



# Routen /
get('/todos') do
    db = SQLite3::Database.new("db/todos.db")
    #[{},{},{}] önskar vi oss
    db.results_as_hash = true

    @data_categories = db.execute("SELECT * FROM categories")


    @data_todos_status_true = db.execute("SELECT todos.*, category_name FROM todos LEFT JOIN categories ON todos.id_category = categories.id WHERE todos.status = true AND todos.user_id = ?;", [session[:user_id]])
    @data_todos_status_false = db.execute("SELECT todos.*, category_name FROM todos LEFT JOIN categories ON todos.id_category = categories.id WHERE todos.status = false AND todos.user_id = ?;", [session[:user_id]])
    id = params[:id].to_i
    slim(:index)
end



