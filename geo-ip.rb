require 'csv'
require 'json'
require 'sinatra'

def load_names_database(lang)
  filename = "./db/GeoLite2-City-CSV_20190212/GeoLite2-City-Locations-#{lang}.csv"
  puts "Loading #{filename}"

  ret = {}

  CSV.foreach(filename, headers: true) do |row|
    id = row['geoname_id'].to_i

    ret[id] = {
      'country_iso_code' => row['country_iso_code'],
      'country_name' => row['country_name'],
      'subdivision_1_iso_code' => row['subdivision_1_iso_code'],
      'subdivision_1_name' => row['subdivision_1_name']
    }.compact.to_json
  end

  ret
end

def load_blocks_database(ip_version)
  filename = "./db/GeoLite2-City-CSV_20190212/GeoLite2-City-Blocks-IP#{ip_version}.csv"
  puts "Loading #{filename}"

  ret = {}

  CSV.foreach(filename, headers: true) do |row|
    id = row['network']

    ret[id] = row['geoname_id'].to_i
  end

  ret
end

puts 'May take up to two minutes to load'
en_names_db = load_names_database('en')
v6_blocks_db = load_blocks_database('v6')
v4_blocks_db = load_blocks_database('v4')

set :bind, '0.0.0.0'
set :show_exceptions, false
set :sessions, false
set :logging, false
set :static, false
set :dump_errors, false
set :lock, false

get '/en/:ip_version/:ip' do |ip_version, ip|
  content_type :json

  geoname_id = nil

  case ip_version
  when '4', 'v4'
    (8..32).reverse_each do |mask_digits|
      geoname_id ||= begin
        ip_w_mask = "#{IPAddr.new("#{ip}/#{mask_digits}").to_s}/#{mask_digits}"

        v4_blocks_db[ip_w_mask]
      end
    end
  when '6', 'v6'
    (19..128).reverse_each do |mask_digits|
      geoname_id ||= begin
        ip_w_mask = "#{IPAddr.new("#{ip}/#{mask_digits}").to_s}/#{mask_digits}"

        v6_blocks_db[ip_w_mask]
      end
    end
  end

  return [404, 'Unable to resolve'] if geoname_id.nil?

  [200, en_names_db[geoname_id]]
rescue
  400
end
