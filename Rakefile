require "json"

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

task :publish do
  f = File.open("data/influxdb.json")
  config = JSON.parse(f.read)
  version = config["version"]
  puts "Detected v#{version}..."

  puts "Building with Middleman..."
  system "bundle exec middleman build"

  puts "Uploading influxdb.js to S3 as influxdb-#{version}.js..."
  system "aws s3 cp build/javascripts/influxdb.js s3://get.influxdb.org/influxdb-#{version}.js"
  system "aws s3 cp build/javascripts/influxdb.js s3://get.influxdb.org/influxdb-latest.js"
end
