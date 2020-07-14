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
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" DATE, "input_text" TEXT, "name_user" TEXT)'
  # Создается таблица с комментариями 
  @db.execute 'CREATE TABLE IF NOT EXISTS Comments ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" DATE, "input_text" TEXT, "post_id" integer, "name_user" TEXT)'
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
  input_text = params[:addNewPost]
  input_name = params[:addName]

  # Проверка на заполненость поля
    if input_text.length <= 0
      @error = 'Введите текст поста'
      return erb :new
    end
    # Добавляем в БД посты
    @db.execute 'INSERT INTO Posts (input_text, created_date, input_name) values (?, datetime(), ?)', [input_text, input_name]

  redirect '/'
end

# Вывод информации о посте
get '/post/:post_id' do

  # Получаем переменную из URL
  post_id = params[:post_id]

  # Получаем список постов
  results = @db.execute 'SELECT * FROM Posts WHERE ID = ?', [post_id]
  
  #Выбираем пост
  @row = results[0]
  
  # Выбираем комментарий для поста
  @comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY ID', [post_id]

  # Возвращаем представление для поста
  erb :post
end

post '/post/:post_id' do
  post_id = params[:post_id]
  input_text = params[:addNewPost]
  input_name = params[:addName]
  
  # Добавляем комментарий в БД
  @db.execute 'INSERT INTO Comments (input_text, created_date, post_id, input_name) values (?, datetime(), ?, ?)', [input_text, post_id, input_name] 
  redirect ('/post/' + post_id)
end

get '/' do
  @results = @db.execute 'SELECT * FROM Posts ORDER BY ID DESC'
  erb :index
end

get '/contacts' do
  erb :contacts
end