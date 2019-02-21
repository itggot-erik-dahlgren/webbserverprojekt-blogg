require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'

enable :sessions

get ('/') do
    slim(:index)
end

get ('/inlogg') do  
    slim(:inlogg)
end

post ('/inlogg/verify') do
    db = SQLite3::Database.new("db/loggin.db")
    db.results_as_hash = true

    result = db.execute("SELECT Username, Password FROM loggin WHERE Username = ?", params["name"])
    if result.length > 0 && BCrypt::Password.new(result.first["Password"]) == params["password"]
        session[:Username] = result.first["Username"]
        redirect('/profile')
    else
        redirect('/')
    end
end

# db = SQLite3::Database.new('db/loggin.db')
#     db.results_as_hash = true

#     sessions[:name] = params["name"]
#     sessions[:pass] = params["pass"]


#     result = db.execute("SELECT * FROM loggin WHERE Username=?",params["name"])

#     if result[:Password] == params["pass"]
#         slim(:index, sessions[:loggedin])
#     else

#     end
#     slim(:/inlogg)