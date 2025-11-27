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
  db = SQLite3::Database.new('db/todos.db') # koppling till databasen
  db.execute("INSERT INTO todos (name, description) VALUES (?,?)",[new_todo,description])

  redirect('/todos') # Hoppa till routen som visar upp alla todos
end
#ändra
post('/todos/:id/update') do
  id = params[:id].to_i
  description = params[:description]
  name = params[:name]

  db = SQLite3::Database.new("db/todos.db")
  db.execute("UPDATE todos SET name=?,description=? WHERE id=?",[name,description,id])

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
  p @special_todo
  slim(:edit)
end



# Routen /
get('/todos') do
    db = SQLite3::Database.new("db/todos.db")
    #[{},{},{}] önskar vi oss
    db.results_as_hash = true

    @data_todos_status_true = db.execute("SELECT * FROM todos WHERE status = true")
    @data_todos_status_false = db.execute("SELECT * FROM todos WHERE status = false")

    @data_todos = db.execute("SELECT * FROM todos")
    id = params[:id].to_i
    slim(:index)
end



