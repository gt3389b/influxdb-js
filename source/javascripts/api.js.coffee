window.InfluxDB = class InfluxDB
  constructor: (@host, @port, @username, @password) ->

  test: () ->
    return true

  createDatabase: (databaseName, callback) ->
    url = @url("db")
    data = {name: databaseName}
    $.post url, JSON.stringify(data), callback

  deleteDatabase: (databaseName) ->
    url = @url("db")
    data = {name: databaseName}
    $.post url, JSON.stringify(data)

  readPoint: (seriesName, callback) ->
    url = @url("db/foo/series")
    query = "SELECT * FROM #{seriesName};"
    url += "&q=" + encodeURIComponent(query)
    data = {name: name}
    $.get url, JSON.stringify(data), callback

  writePoint: (seriesName, values, options, callback) ->
    options ?= {}
    datum = {points: [], name: seriesName, columns: []}
    point = []

    for k, v of values
      point.push v
      datum.columns.push k

    datum.points.push point
    data = [datum]

    url = @seriesUrl("foo")
    $.post url, JSON.stringify(data), callback

  url: (action) ->
    "http://#{@host}:#{@port}/#{action}?username=#{@username}&password=#{@password}"

  seriesUrl: (databaseName, query) ->
    @url("db/#{databaseName}/series")
