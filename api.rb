require "sinatra"
require "base64"

require "sinatra/reloader" if development?
require "byebug" if development?

require_relative "aggregate"


CONTENT_TYPE_JSON = { "Content-Type" => "application/json" }.freeze
CONTENT_TYPE_HTML = { "Content-Type" => "text/html; charset=utf-8" }.freeze


get "/health" do
  200
end

post "/aggregate" do
  halt 401 unless authorized?(request.env)

  aggregate_results
  201
end

get "/aggregated_results.json" do
  last_modified File.mtime(OUTPUT_FILE_PATH)
  json_str = File.read(OUTPUT_FILE_PATH)

  [200, CONTENT_TYPE_JSON, json_str]
end

get "/" do
  last_modified File.mtime(OUTPUT_FILE_PATH)
  @jumps = read_jumps_from_file

  erb :index
end

### Private helper methods ###

# Performs HTTP basic authentication, returning true if authorized.
def authorized?(headers)
  auth_header = headers["HTTP_AUTHORIZATION"]
  return false unless auth_header
  return false unless auth_header.include?("Basic ")

  auth_header = auth_header.gsub("Basic ", "")
  secret = Base64.decode64(auth_header)
  return false unless secret.include?(":")

  username, password = secret.split(":")
  username == ENV["BASIC_AUTH_USERNAME"] && password == ENV["BASIC_AUTH_PASSWORD"]
end
