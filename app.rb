require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'lepra.db'
  @db.results_as_hash = true
end

# Вызывается каждый раз при перезагрузке страницы
before do
  init_db # Инициализация БД
end

# Вызывается каждый раз при конфигурации приложения
# Изменился код либо перезагрузилась страница
configure do
  init_db
  # Создается таблица если таблица не существует 
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" DATE, "content" TEXT)'
end

configure do
  enable :sessions
end

# Браузер получает страницу с сервера
get '/new/' do
 erb :new
end

# Браузер отправляет страницу с сервера
post '/new' do
  inputText = params[:addNewPost]
  erb "Введено: #{inputText}"
end

get '/' do
  erb '<h1>Добро пожаловать это Блог</h1>'
end
