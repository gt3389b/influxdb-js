#= require influxdb
#= require ua-parser
#= require referers
#= require vendor/node/querystring
#= require vendor/node/url
#= require referer-parser
#= require_self

window.getGeoByIP = () ->
  $.get "http://geoip.influxdb.com/"

