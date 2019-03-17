require 'sinatra'
require 'slim'
require 'sqlite3'
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

get ('/error') do
    slim(:error)
end

get ('/:user_id/profile') do
    if session[:Username].nil?
        slim(:error)
    else
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    result = db.execute("SELECT Username, Information, Post_Id, User_Id FROM posts")
    slim(:profile, locals: {
        user: session[:Username],
        posts: result
    })
    end
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

get ("/profile/:post_id/edit_post") do
    slim(:edit_post, locals: {
        user: session[:Post_Id]
    })
end

post ('/inlogg/verify') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    result = db.execute("SELECT User_Id, Username, Password FROM users WHERE Username = ?", params["name"])
    if result.length > 0 && BCrypt::Password.new(result.first["Password"]) == params["password"]
        session[:Username] = result.first["Username"]
        session[:User_Id] = result.first["User_Id"]
        redirect("/#{session[:User_Id]}/profile")
    else
        redirect('/error')
    end
end

post ('/:user_id/post') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    post = params["textarea"]
    if post.length > 0
        result = db.execute("INSERT INTO posts (Username, Information, User_Id) VALUES (?,?,?)", session[:Username], post, session[:User_Id])
        redirect("/#{session[:User_Id]}/profile")
    else
        redirect('/error')
    end
end

post ('/edit_post') do
    db = SQLite3::Database.new('db/users.db')
    db.results_as_hash = true

    post = params["textarea"]
    db.execute("UPDATE posts SET Information='#{post}' WHERE Post_Id=?", session[:Post_Id])
    redirect("/#{session[:User_Id]}/profile")
end

post ('/profile/:post_id/delete_post') do
    db = SQLite3::Database.new('db/users.db')
    db.results_as_hash = true

    db.execute("DELETE FROM posts WHERE Post_Id=?", session[:Post_Id])
    redirect("#{session[:User_Id]}/profile")
end