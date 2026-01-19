require "sinatra"
require "json"
require "net/http"
require "uri"
require "openssl"

require_relative "helpers"

helpers ViewHelpers

set :bind, ENV.fetch("BIND", "127.0.0.1")
set :port, ENV.fetch("PORT", "4567").to_i

API_BASE_URL = ENV.fetch("API_BASE_URL") # e.g. https://api.example.com/
LIST_PATH = ENV.fetch("LIST_PATH", "/items") # GET
SHOW_PATH = ENV.fetch("SHOW_PATH", ENV.fetch("UPDATE_PATH", "/items/%{id}")) # GET (optional)
UPDATE_PATH = ENV.fetch("UPDATE_PATH", "/items/%{id}") # PATCH/PUT
UPDATE_METHOD = ENV.fetch("UPDATE_METHOD", "PATCH").upcase # PATCH or PUT

PRIMARY_KEY = ENV.fetch("PRIMARY_KEY", "id").to_s
LIMIT = ENV.fetch("LIMIT", "200").to_i
VERIFY_SSL = ENV.fetch("VERIFY_SSL", "true").downcase != "false"

def api_headers
  headers = { "Accept" => "application/json" }

  token = ENV["API_TOKEN"]
  headers["Authorization"] = "Bearer #{token}" if token && !token.strip.empty?

  key = ENV["API_KEY"]
  key_header = ENV.fetch("API_KEY_HEADER", "X-API-Key")
  headers[key_header] = key if key && !key.strip.empty?

  headers
end

def build_uri(path_or_url)
  # Allow full URL in LIST_PATH/UPDATE_PATH, otherwise treat as relative to API_BASE_URL.
  if path_or_url =~ %r{\Ahttps?://}i
    URI(path_or_url)
  else
    base = API_BASE_URL.end_with?("/") ? API_BASE_URL : (API_BASE_URL + "/")
    rel = path_or_url.start_with?("/") ? path_or_url[1..] : path_or_url
    URI.join(base, rel)
  end
end

def http_for(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  if http.use_ssl? && !VERIFY_SSL
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  http
end

def api_request(method, path_or_url, body: nil, headers: {})
  uri = build_uri(path_or_url)
  req_klass =
    case method.to_s.upcase
    when "GET" then Net::HTTP::Get
    when "POST" then Net::HTTP::Post
    when "PUT" then Net::HTTP::Put
    when "PATCH" then Net::HTTP::Patch
    when "DELETE" then Net::HTTP::Delete
    else
      halt 500, "Unsupported HTTP method: #{method}"
    end

  req = req_klass.new(uri)
  (api_headers.merge(headers)).each { |k, v| req[k] = v }

  if body
    req["Content-Type"] ||= "application/json"
    req.body = body.is_a?(String) ? body : JSON.generate(body)
  end

  res = http_for(uri).request(req)
  [uri, res]
end

def parse_json(res)
  JSON.parse(res.body)
rescue JSON::ParserError
  nil
end

def extract_rows(parsed)
  return parsed if parsed.is_a?(Array)

  if parsed.is_a?(Hash)
    return parsed["data"] if parsed["data"].is_a?(Array)
    return parsed["items"] if parsed["items"].is_a?(Array)
    return parsed["results"] if parsed["results"].is_a?(Array)

    any_array = parsed.values.find { |v| v.is_a?(Array) }
    return any_array if any_array
  end

  []
end

def symbolize_row(row)
  return {} unless row.is_a?(Hash)
  row.each_with_object({}) do |(k, v), acc|
    acc[k.to_s.to_sym] = v
  end
end

def compute_columns(rows)
  if (cols = ENV["COLUMNS"]) && !cols.strip.empty?
    return cols.split(",").map(&:strip).reject(&:empty?)
  end

  keys = rows.flat_map { |r| r.keys.map(&:to_s) }.uniq
  keys.sort
end

def list_url
  path = LIST_PATH
  return path if LIMIT <= 0

  # Optional convenience: add ?limit=LIMIT if not already present.
  return path if path.include?("?")
  "#{path}?limit=#{LIMIT}"
end

get "/" do
  _uri, res = api_request("GET", list_url)
  parsed = parse_json(res)

  unless res.is_a?(Net::HTTPSuccess)
    msg = (parsed.is_a?(Hash) && (parsed["error"] || parsed["message"])) ? (parsed["error"] || parsed["message"]) : res.body
    halt 502, erb(:api_error, locals: { error_message: msg.to_s })
  end

  raw_rows = extract_rows(parsed)
  rows = raw_rows.map { |r| symbolize_row(r) }.select { |r| r.key?(PRIMARY_KEY.to_sym) }
  columns = compute_columns(rows)

  erb :index, locals: {
    table_name: "REST: #{LIST_PATH}",
    primary_key: PRIMARY_KEY,
    columns: columns,
    editable_columns: columns - [PRIMARY_KEY],
    rows: rows,
    limit: LIMIT
  }
end

get "/edit/:id" do
  id = params[:id].to_s
  show_url = (SHOW_PATH % { id: id })
  _uri, res = api_request("GET", show_url)
  parsed = parse_json(res)

  unless res.is_a?(Net::HTTPSuccess)
    msg = (parsed.is_a?(Hash) && (parsed["error"] || parsed["message"])) ? (parsed["error"] || parsed["message"]) : res.body
    halt 502, erb(:api_error, locals: { error_message: msg.to_s })
  end

  row = symbolize_row(parsed.is_a?(Hash) ? parsed : {})
  columns = compute_columns([row])

  erb :edit, locals: {
    table_name: "REST: #{SHOW_PATH}",
    primary_key: PRIMARY_KEY,
    columns: columns,
    editable_columns: columns - [PRIMARY_KEY],
    row: row
  }
end

post "/edit/:id" do
  id = params[:id].to_s
  payload = params.dup
  payload.delete("splat")
  payload.delete("captures")

  # Only update editable columns
  payload.delete(PRIMARY_KEY)

  update_url = (UPDATE_PATH % { id: id })
  _uri, res = api_request(UPDATE_METHOD, update_url, body: payload)
  parsed = parse_json(res)

  unless res.is_a?(Net::HTTPSuccess)
    msg = (parsed.is_a?(Hash) && (parsed["error"] || parsed["message"])) ? (parsed["error"] || parsed["message"]) : res.body
    halt 502, erb(:api_error, locals: { error_message: msg.to_s })
  end

  redirect "/"
end

patch "/api/rows/:id" do
  content_type :json

  id = params[:id].to_s
  updates = JSON.parse(request.body.read)
  halt 400, { error: "JSON object required" }.to_json unless updates.is_a?(Hash)

  updates.delete(PRIMARY_KEY)

  update_url = (UPDATE_PATH % { id: id })
  _uri, res = api_request(UPDATE_METHOD, update_url, body: updates)
  parsed = parse_json(res)

  unless res.is_a?(Net::HTTPSuccess)
    msg = (parsed.is_a?(Hash) && (parsed["error"] || parsed["message"])) ? (parsed["error"] || parsed["message"]) : res.body
    status 502
    return({ error: msg.to_s }.to_json)
  end

  { ok: true }.to_json
end

