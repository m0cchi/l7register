require 'bundler'
Bundler.require
require_relative '../lib/l7register/webapp'
path = ARGV[0]

if path
  WebApp.load(path)
else
  puts 'error'
  exit
end

WebApp.run!
