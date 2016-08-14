require 'sinatra'
require 'yaml'
require 'json'

class WebApp < Sinatra::Base
  @@store = {}
  @@port = 4567
  @@store_path = ''

  configure do
    set :port, (@@port || 4567)
  end

  get '/' do
    'top'
  end

  get '/:domain' do
    begin
      data = @@store[params['domain']]
      data.to_json.dump
    rescue
      {ok: false}.to_json.dump
    end
  end

  get '/:domain/:param' do
    begin
      data = @@store[params['domain']]
      data[params['param'].to_sym].to_json.dump
    rescue
      {ok: false}.to_json.dump
    end
  end

  post '/:domain' do
    map = {}
    begin
      map[:ssl_cert] = params['ssl_cert']
      map[:ssl_cert_key] = params['ssl_cert_key']
      map[:ssl] = !(map[:ssl_cert].nil?)
      map[:backend] = params['backend']
      @@store[params['domain']] = map
      map.to_json.dump
    rescue
      {ok: false}.to_json.dump      
    end
  end

  class << self
    def load(path)
      yaml = YAML.load_file(path)
      port = (yaml[:port] || @@port.to_s)
      @@port = port.to_i > 0 ? port.to_i : @@port
      @@store_path = yaml[:store_path]
      if File.exist?(@@store_path)
        @@store = YAML.load_file(@@store_path)
      end
    end

    def finally
      File.open(@@store_path, 'w') do |e|
        YAML.dump(@@store, e)
      end
    end
  end
end

at_exit {
  WebApp.finally
}
