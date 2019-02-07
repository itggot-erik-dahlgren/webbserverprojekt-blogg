require 'sinatra'
require 'slim'
require 'sqlite3'

get ('/') do
    slim(:index)
end

get ('/inlogg') do
    slim(:inlogg)
end