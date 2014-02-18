window.InfluxDB = class InfluxDB
  constructor: (opts) ->
    opts = {} unless opts
    @host = opts.host || "localhost"
    @port = opts.port || 8086
    @username = opts.username || "root"
    @password = opts.password || "root"
    @database = opts.database

  ###
  # Databases
  #
  # GET    /db
  # POST   /db
  # DELETE /db/:db
  ###

  getDatabases: () ->
    url = @url("db")
    $.get url

  createDatabase: (databaseName, callback) ->
    url = @url("db")
    data = {name: databaseName}
    $.post url, JSON.stringify(data), callback

  deleteDatabase: (databaseName) ->
    url = @url("db/#{databaseName}")
    $.ajax type: "DELETE", url: url

  ###
  # Database Users
  #
  # GET  /db/:db/users
  # POST /db/:db/users
  # GET  /db/:db/user/:name
  # POST /db/:db/user/:name
  # GET  /db/:db/authenticate
  ###

  getDatabaseUsers: (databaseName) ->
    url = @url("db/#{databaseName}/users")
    $.get url

  createUser: (databaseName, username, password, callback) ->
    url = @url("db/#{databaseName}/users")
    data = {name: username, password: password}
    $.post url, JSON.stringify(data), callback

  deleteDatabaseUser: (databaseName, username) ->
    url = @url("db/#{databaseName}/users/#{username}")
    $.ajax type: "DELETE", url: url

  getDatabaseUser: (databaseName, username) ->
    url = @url("db/#{databaseName}/users/#{username}")
    $.get url

  updateDatabaseUser: (databaseName, username, params, callback) ->
    url = @url("db/#{databaseName}/users/#{username}")
    $.post url, JSON.stringify(params), callback

  authenticateDatabaseUser: () ->
    url = @url("db/#{@database}/authenticate")
    $.get url

  ###
  # Cluster Admins
  #
  # GET    /cluster_admins
  # POST   /cluster_admins
  # DELETE /cluster_admins/:username
  # GET    /cluster_admins/authenticate
  ###

  getClusterAdmins: () ->
    url = @url("cluster_admins")
    $.get url

  deleteClusterAdmin: (username) ->
    url = @url("cluster_admins/#{username}")
    $.ajax type: "DELETE", url: url

  createClusterAdmin: (username, password, callback) ->
    data = {name: username, password: password}
    url = @url("cluster_admins")
    $.post url, JSON.stringify(data)

  authenticateClusterAdmin: (username, password, callback) ->
    url = @url("cluster_admins/authenticate")
    $.get url

  ###
  # Continuous Queries
  #
  # GET    /db/:db/continuous_queries
  # POST   /db/:db/continuous_queries
  # DELETE /db/:db/continuous_queries/:id
  ###

  getContinuousQueries: (databaseName) ->
    url = @url("db/#{databaseName}/continuous_queries")
    $.get url

  deleteContinuousQuery: (databaseName, id) ->
    url = @url("db/#{databaseName}/continuous_queries/#{id}")
    $.ajax type: "DELETE", url: url

  ###
  # User Interfaces
  #
  # GET /interfaces
  ###

  getInterfaces: () ->
    url = @url("interfaces")
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
