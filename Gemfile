source 'https://rubygems.org'
gemspec

if ENV['RAILS_SOURCE']
  gemspec path: ENV['RAILS_SOURCE']
else
  # Need to get rails source beacause the gem doesn't include tests
  version = ENV['RAILS_VERSION'] || begin
    require 'net/http'
    require 'yaml'
    spec = eval(File.read('activerecord-monetdb-adapter.gemspec'))
    version = spec.dependencies.detect{ |d|d.name == 'activerecord' }.requirement.requirements.first.last.version
    major, minor, tiny = version.split('.')
    uri = URI.parse "https://rubygems.org/api/v1/versions/activerecord.yaml"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    YAML.load(http.request(Net::HTTP::Get.new(uri.request_uri)).body).select do |data|
      a, b, c = data['number'].split('.')
      !data['prerelease'] && major == a && (minor.nil? || minor == b)
    end.first['number']
  end
  gem 'rails', git: "git://github.com/rails/rails.git", tag: "v#{version}"
end

if ENV['AREL']
  gem 'arel', path: ENV['AREL']
end

group :development do
  gem 'mocha'
  gem 'minitest'
  gem 'minitest-spec-rails'
  gem 'pry'
end

gem 'monetdb-sql', :git => "https://gitlab.c3sl.ufpr.br/simcaq/monetdb-sql.git"
