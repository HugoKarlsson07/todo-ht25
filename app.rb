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

  db = SQLite3::Database.new("db/todoss.db")
  db.execute("UPDATE todos SET name=?,description=? WHERE id=?",[name,description,id])

  redirect('/todos')
end



# Routen /
get('/todos') do
    db = SQLite3::Database.new("db/todos.db")
    #[{},{},{}] önskar vi oss
    db.results_as_hash = true

    @data_todos = db.execute("SELECT * FROM todos")
    id = params[:id].to_i
    @special_todo = db.execute("SELECT * FROM todos WHERE id = ?",id).first
    slim(:index)
end



