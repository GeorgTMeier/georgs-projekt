require "sinatra"
require "sequel"
require "json"
require "bigdecimal"
require "date"
require "time"

set :bind, ENV.fetch("BIND", "127.0.0.1")
set :port, ENV.fetch("PORT", "4567").to_i

TABLE_NAME = ENV.fetch("TABLE", "people").to_sym
PRIMARY_KEY = ENV.fetch("PRIMARY_KEY", "id").to_s
LIMIT = ENV.fetch("LIMIT", "200").to_i

def db
  return @db if defined?(@db) && @db

  if (url = ENV["DATABASE_URL"]) && !url.strip.empty?
    @db = Sequel.connect(url)
    return @db
  end

  # Fallback: build connection from PG* env vars
  host = ENV.fetch("PGHOST", "127.0.0.1")
  port = ENV.fetch("PGPORT", "5432").to_i
  database = ENV.fetch("PGDATABASE")
  user = ENV.fetch("PGUSER")
  password = ENV["PGPASSWORD"]

  @db = Sequel.connect(
    adapter: "postgres",
    host: host,
    port: port,
    database: database,
    user: user,
    password: password
  )
end

def dataset
  db[TABLE_NAME]
end

def schema_types
  return @schema_types if defined?(@schema_types) && @schema_types

  # schema(TABLE) returns: [[col, {type:, ...}], ...]
  @schema_types = db.schema(TABLE_NAME).to_h do |(col, info)|
    [col.to_s, info[:type]]
  end
end

def cast_value(type, raw)
  return nil if raw.nil?
  s = raw.is_a?(String) ? raw.strip : raw
  return nil if s == ""

  case type
  when :integer, :bignum
    Integer(s)
  when :float
    Float(s)
  when :decimal
    BigDecimal(s.to_s)
  when :boolean
    str = s.to_s.downcase
    return true if %w[true t 1 yes y].include?(str)
    return false if %w[false f 0 no n].include?(str)
    halt 400, { error: "Invalid boolean: #{s.inspect}" }.to_json
  when :date
    Date.parse(s.to_s)
  when :datetime, :timestamp, :timestamptz
    Time.parse(s.to_s)
  else
    s.to_s
  end
rescue ArgumentError => e
  halt 400, { error: "Invalid value #{raw.inspect} for type #{type}: #{e.message}" }.to_json
end

def pk_type
  schema_types.fetch(PRIMARY_KEY, :string)
end

def columns
  @columns ||= dataset.columns.map(&:to_s)
end

def editable_columns
  columns - [PRIMARY_KEY]
end

get "/" do
  rows = dataset.limit(LIMIT).all
  erb :index, locals: {
    table_name: TABLE_NAME.to_s,
    primary_key: PRIMARY_KEY,
    columns: columns,
    editable_columns: editable_columns,
    rows: rows,
    limit: LIMIT
  }
end

get "/edit/:id" do
  id = cast_value(pk_type, params[:id])
  row = dataset.where(Sequel.identifier(PRIMARY_KEY) => id).first
  halt 404, "Row not found" unless row

  erb :edit, locals: {
    table_name: TABLE_NAME.to_s,
    primary_key: PRIMARY_KEY,
    columns: columns,
    editable_columns: editable_columns,
    row: row
  }
end

post "/edit/:id" do
  id = cast_value(pk_type, params[:id])
  updates = {}

  editable_columns.each do |col|
    next unless params.key?(col)
    updates[col.to_sym] = cast_value(schema_types.fetch(col, :string), params[col])
  end

  dataset.where(Sequel.identifier(PRIMARY_KEY) => id).update(updates)
  redirect "/"
end

patch "/api/rows/:id" do
  content_type :json

  id = cast_value(pk_type, params[:id])
  payload = JSON.parse(request.body.read)
  halt 400, { error: "JSON object required" }.to_json unless payload.is_a?(Hash)

  updates = {}
  payload.each do |k, v|
    next unless editable_columns.include?(k.to_s)
    updates[k.to_sym] = cast_value(schema_types.fetch(k.to_s, :string), v)
  end

  halt 400, { error: "No editable columns provided" }.to_json if updates.empty?

  affected = dataset.where(Sequel.identifier(PRIMARY_KEY) => id).update(updates)
  halt 404, { error: "Row not found" }.to_json if affected == 0

  { ok: true }.to_json
end

error Sequel::DatabaseError do
  err = env["sinatra.error"]

  if request.path_info.start_with?("/api/")
    content_type :json
    status 500
    { error: err.message }.to_json
  else
    content_type :html
    status 500
    erb :db_error, locals: {
      table_name: TABLE_NAME.to_s,
      primary_key: PRIMARY_KEY,
      error_message: err.message
    }
  end
end
