window.InfluxDB = class InfluxDB
  constructor: (opts) ->
    opts = {} unless opts
    @host = opts.host || "localhost"
    @hosts = opts.hosts || [@host]
    @port = opts.port || 8086
    @username = opts.username || "root"
    @password = opts.password || "root"
    @database = opts.database
    @ssl = opts.ssl || false
    @isCrossOrigin = window.location.host not in @hosts
    @username = encodeURIComponent(@username)
    @password = encodeURIComponent(@password)

  ###
  # Databases
  ###

  showDatabases: () ->
    @query("SHOW DATABASES")

  createDatabase: (databaseName, callback) ->
    @query("CREATE DATABASE #{databaseName}")

  dropDatabase: (databaseName) ->
    @query("DROP DATABASE #{databaseName}")

  ###
  # Database Users
  ###

  showUsers: () ->
    @query("SHOW USERS")

  createUser: (databaseName, username, password, callback) ->
    @query("CREATE USER #{username} WITH PASSWORD '#{password}'")

  dropUser: (databaseName, username) ->
    @query("DROP USER #{username}")

  ###
  # Retention Policies
  ###

  showRetentionPolicies: (databaseName) ->
    @queryDatabase("SHOW RETENTION POLICIES #{databaseName}")

  createRetentionPolicy: (databaseName, name, duration, replication, isDefault) ->
    debugger
    @query("CREATE RETENTION POLICY #{name} ON #{databaseName} DURATION #{duration} REPLICATION #{replication}#{if isDefault then " DEFAULT" else ""}")

  deleteRetentionPolicy: (name) ->
    @queryDatabase("DROP RETENTION POLICY #{name}")


  ###
  # Continuous Queries
  ###

  showContinuousQueries: (databaseName) ->
    @query("SHOW CONTINUOUS QUERIES")

  deleteContinuousQuery: (databaseName, id) ->
    @query("DROP CONTINUOUS QUERY #{id}")


  ###
  # Queries
  ###

  query: (query, callback) ->
    @get @path("query", {q: query}), callback

  queryDatabase: (query, callback) ->
    @get @path("query", {q: query, db: @database}), callback

  get: (path, callback) ->
    new Promise (resolve, reject) =>
      reqwest(
        method: 'get'
        type: 'json'
        url: @url(path)
        crossOrigin: @isCrossOrigin
        success: (data) =>
          resolve(data)
          callback @formatPoints(data) if callback
        error: (data) =>
          reject(data)
      )

  post: (path, data, callback) ->
    new Promise (resolve, reject) =>
      reqwest(
        method: 'post'
        type: 'json'
        url: @url(path)
        crossOrigin: @isCrossOrigin
        contentType: 'application/json'
        data: if typeof data == "string" then data else JSON.stringify(data)
        success: (data) =>
          resolve(data)
        error: (data) =>
          reject(data)
      )

  formatPoints: (data) ->
    data.map (datum) ->
      series =
        name: datum.name
        points: datum.points.map (p) ->
          point = {}
          datum.columns.forEach (column, index) ->
            point[column] = p[index]
          t = new Date(0)
          t.setUTCSeconds Math.round(point.time/1000)
          point.time = t
          point

  read: (query) ->
    @queryDatabase("SELECT value FROM cpu", "foo")

  write: (seriesName, values, tags, callback) ->
    tags ?= {}
    datum = {points: [], name: seriesName, columns: []}
    point = []

    for k, v of values
      point.push v
      datum.columns.push k

    datum.points.push point
    data = [datum]

    @post @path("db/#{@database}/series"), data, callback

  writeJSON: (payload, callback) ->
    @post @path("write", {db: @database}), payload, callback

  writePoint: (seriesName, values, options, callback) ->
    options ?= {}
    datum = {points: [], name: seriesName, columns: []}
    point = []

    for k, v of values
      point.push v
      datum.columns.push k

    datum.points.push point
    data = [datum]

    @post @path("db/#{@database}/series"), data, callback

  writeSeries: (seriesData, callback) ->
    @post @path("db/#{@database}/series"), seriesData, callback

  path: (action, opts) ->
    path  = "#{action}?u=#{@username}&p=#{@password}"
    path += "&q=" + encodeURIComponent(opts.q) if opts? and opts.q
    path += "&db=" + encodeURIComponent(opts.db) if opts? and opts.db
    path

  url: (path) ->
    host = @hosts.shift();
    @hosts.push(host);
    "#{if @ssl then "https" else "http"}://#{host}:#{@port}/#{path}"

