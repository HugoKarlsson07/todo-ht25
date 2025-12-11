require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'

#ta bort 
post('/todos/:id/delete') do
    #hämtar todo
    id = params[:id].to_i
    #gör en koppling till databasen
    db = SQLite3::Database.new("db/todos.db")

    db.execute("DELETE FROM todos WHERE id=?",id)

    redirect('/todos')
end

#skappar todo
post('/todo') do
  new_todo = params[:new_todo] # Hämta datan ifrån formuläret
  description = params[:description].to_s 
  category_name = params[:category_name]


  db = SQLite3::Database.new('db/todos.db') # koppling till databasen
  db.execute("INSERT INTO todos (name, description, id_category) VALUES (?,?,?)",[new_todo,description,category_name])

  redirect('/todos') # Hoppa till routen som visar upp alla todos
end
#ändra
post('/todos/:id/update') do
  id = params[:id].to_i
  description = params[:description]
  name = params[:name]
  category_name = params[:category_name]

  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET name=?,description=?,id_category=? WHERE id=?",[name,description,category_name,id])
   
  redirect('/todos')
end

post('/todos/:id/klar') do
  id = params[:id].to_i
  status = 1
  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET status=? WHERE id=?",[status,id])
  redirect('/todos')
end  

post('/todos/:id/ice') do
  id = params[:id].to_i
  status = 0
  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET status=? WHERE id=?",[status,id])
  redirect('/todos')
end


get('/todos/:id/edit') do
  db = SQLite3::Database.new("db/todos.db")
  db.results_as_hash = true
  id = params[:id].to_i
  
  
  @special_todo = db.execute("SELECT * FROM todos WHERE id = ?",id).first
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


    @data_todos_status_true = db.execute("SELECT todos.*, category_name FROM todos LEFT JOIN categories ON todos.id_category = categories.id WHERE todos.status = true;")
    @data_todos_status_false = db.execute("SELECT todos.*, category_name FROM todos LEFT JOIN categories ON todos.id_category = categories.id WHERE todos.status = false;")
    id = params[:id].to_i
    slim(:index)
end



