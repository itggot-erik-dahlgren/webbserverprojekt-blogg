require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'

enable :sessions

get ('/') do
    slim(:index)
end

get ('/inlogg') do  
    slim(:inlogg)
end

get ('/create') do
    slim(:create)
end

post ('/create/new') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true
    
    pass = BCrypt::Password.create(params["password"])
    if db.execute("SELECT Username FROM users WHERE Username=?", params["name"]) != true
        result = db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", params["name"], pass)
    end
    redirect('/')
end

post ('/inlogg/verify') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    result = db.execute("SELECT Username, Password FROM users WHERE Username = ?", params["name"])
    if result.length > 0 && BCrypt::Password.new(result.first["Password"]) == params["password"]
        session[:Username] = result.first["Username"]
        redirect("/profile") ## redirect("/profile/:Username") Försök att supportera fler än 1 user
    else
        redirect('/')
    end
end

post ('/post') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    post = params["textarea"]
    result = db.execute("INSERT INTO posts (Username, Information) VALUES (?,?)", session[:Username], post)
    redirect('/profile')
end

get ('/profile') do
    slim(:profile, locals: {user: session[:Username]})
end