window.InfluxDB = class InfluxDB
  constructor: (opts) ->
    opts = {} unless opts
    @host = opts.host || "localhost"
    @port = opts.port || 8086
    @username = opts.username || "root"
    @password = opts.password || "root"
    @database = opts.database

  createDatabase: (databaseName, callback) ->
    url = @url("db")
    data = {name: databaseName}
    $.post url, JSON.stringify(data), callback

  deleteDatabase: (databaseName) ->
    url = @url("db/#{databaseName}")
    $.ajax type: "DELETE", url: url

  getDatabases: () ->
    url = @url("dbs")
    $.get url

  getDatabaseUsers: (databaseName) ->
    url = @url("db/#{databaseName}/users")
    $.get url

  getInterfaces: () ->
    url = @url("interfaces")
    $.get url

  getClusterAdmins: () ->
    url = @url("cluster_admins")
    $.get url

  authenticateClusterAdmin: (username, password, callback) ->
    url = @url("cluster_admins/authenticate")
    $.get url

  createClusterAdmin: (username, password, callback) ->
    data = {username: username, password: password}
    url = @url("cluster_admins")
    $.post url, JSON.stringify(data)

  createUser: (databaseName, username, password, callback) ->
    url = @url("db/#{databaseName}/users")
    data = {username: username, password: password}
    $.post url, JSON.stringify(data), callback

  authenticateDatabaseUser: () ->
    url = @url("db/#{@database}/authenticate")
    $.get url

  readPoint: (fieldNames, seriesNames, callback) ->
    url = @url("db/#{@database}/series")
    query = "SELECT #{fieldNames} FROM #{seriesNames};"
    url += "&q=" + encodeURIComponent(query)
    $.get url, null, callback

  _readPoint: (query, callback) ->
    url = @seriesUrl(@database)
    url += "&q=" + encodeURIComponent(query)
    $.get url, {}, callback

  query: (query, callback) ->
    url = @seriesUrl(@database)
    url += "&q=" + encodeURIComponent(query)
    if callback
      $.getJSON url, (data) ->
        callback data[0].points.map (p) ->
          point = {}
          data[0].columns.forEach (column, index) ->
            point[column] = p[index]
          t = new Date(0)
          t.setUTCSeconds Math.round(point.time/1000)
          point.time = t
          point
    else
      $.getJSON url

  writePoint: (seriesName, values, options, callback) ->
    options ?= {}
    datum = {points: [], name: seriesName, columns: []}
    point = []

    for k, v of values
      point.push v
      datum.columns.push k

    datum.points.push point
    data = [datum]

    url = @seriesUrl(@database)
    $.post url, JSON.stringify(data), callback

  url: (action) ->
    "http://#{@host}:#{@port}/#{action}?u=#{@username}&p=#{@password}"

  seriesUrl: (databaseName, query) ->
    @url("db/#{databaseName}/series")
