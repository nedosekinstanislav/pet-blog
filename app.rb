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
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" DATE, "content" TEXT)'
  # Создается таблица с комментариями 
  @db.execute 'CREATE TABLE IF NOT EXISTS Comments ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" DATE, "content" TEXT, "post_id" integer)'
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

  # Проверка на заполненость поля
    if input_text.length <= 0
      @error = 'Введите текст поста'
      return erb :new
    end
    # Добавляем в БД постов
    @db.execute 'INSERT INTO Posts (input_text, created_date) values (?, datetime())', [input_text]

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
  erb :post
end

post '/post/:post_id' do
  post_id = params[:post_id]
  input_text = params[:addNewPost]
  erb " Вы ввели #{input_text} с таким номером #{post_id}"
end

get '/' do
  @results = @db.execute 'SELECT * FROM Posts ORDER BY ID DESC'
  erb :index
end
