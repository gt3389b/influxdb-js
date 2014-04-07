window.InfluxDB = class InfluxDB
  constructor: (opts) ->
    opts = {} unless opts
    @host = opts.host || "localhost"
    @hosts = opts.hosts || [opts.host] || ["localhost"]
    @port = opts.port || 8086
    @username = opts.username || "root"
    @password = opts.password || "root"
    @database = opts.database
    @ssl = opts.ssl || false
    @max_retries = opts.max_retries || 20

  ###
  # Databases
  #
  # GET    /db
  # POST   /db
  # DELETE /db/:db
  ###

  getDatabases: () ->
    path = @path("db")
    @get(path)

  createDatabase: (databaseName, callback) ->
    path = @path("db")
    data = {name: databaseName}
    @post path, JSON.stringify(data), callback

  deleteDatabase: (databaseName) ->
    path = @path("db/#{databaseName}")
    @delete path

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
    path = @path("db/#{databaseName}/users")
    @get(path)

  createUser: (databaseName, username, password, callback) ->
    path = @path("db/#{databaseName}/users")
    data = {name: username, password: password}
    @post path, JSON.stringify(data), callback

  deleteDatabaseUser: (databaseName, username) ->
    path = @path("db/#{databaseName}/users/#{username}")
    @delete(path)

  getDatabaseUser: (databaseName, username) ->
    path = @path("db/#{databaseName}/users/#{username}")
    @get(path)

  updateDatabaseUser: (databaseName, username, params, callback) ->
    path = @path("db/#{databaseName}/users/#{username}")
    @post path, JSON.stringify(params), callback

  authenticateDatabaseUser: () ->
    url = @url("db/#{@database}/authenticate")
    $.get(url)

  ###
  # Cluster Admins
  #
  # GET    /cluster_admins
  # POST   /cluster_admins
  # DELETE /cluster_admins/:username
  # POST   /cluster_admins/:username
  # GET    /cluster_admins/authenticate
  ###

  getClusterAdmins: () ->
    path = @path("cluster_admins")
    @get(path)

  deleteClusterAdmin: (username) ->
    path = @path("cluster_admins/#{username}")
    @delete(path)

  createClusterAdmin: (username, password, callback) ->
    path = @path("cluster_admins")
    data = {name: username, password: password}
    @post path, JSON.stringify(data)

  updateClusterAdmin: (username, params, callback) ->
    path = @path("cluster_admins/#{username}")
    @post path, JSON.stringify(params), callback

  authenticateClusterAdmin: (username, password, callback) ->
    url = @url("cluster_admins/authenticate")
    $.get(url)

  ###
  # Continuous Queries
  #
  # GET    /db/:db/continuous_queries
  # POST   /db/:db/continuous_queries
  # DELETE /db/:db/continuous_queries/:id
  ###

  getContinuousQueries: (databaseName) ->
    path = @path("db/#{databaseName}/continuous_queries")
    @get(path)

  deleteContinuousQuery: (databaseName, id) ->
    path = @path("db/#{databaseName}/continuous_queries/#{id}")
    @delete(path)

  ###
  # Cluster Servers & Shards
  #
  # GET    /cluster/servers
  # GET    /cluster/shards
  # POST   /cluster/shards
  # DELETE /cluster/shards/:id
  ###

  getClusterServers: () ->
    path = @path("cluster/servers")
    @get(path)

  getClusterShards: () ->
    path = @path("cluster/shards")
    @get(path)

  createClusterShard: (startTime, endTime, longTerm, serverIds, callback) ->
    data =
      startTime: startTime
      endTime: endTime
      longTerm: longTerm
      shards: [{serverIds: serverIds}]

    path = @path("cluster/shards")
    @post path, JSON.stringify(data), callback

  deleteClusterShard: (id, serverIds) ->
    path = @path("cluster/shards/#{id}")
    data =
      serverIds: serverIds

    @delete path, JSON.stringify(data)

  ###
  # User Interfaces
  #
  # GET /interfaces
  ###

  getInterfaces: () ->
    path = @path("interfaces")
    @get(path)

  readPoint: (fieldNames, seriesNames, callback) ->
    path = @path("db/#{@database}/series")
    query = "SELECT #{fieldNames} FROM #{seriesNames};"
    url += "&q=" + encodeURIComponent(query)
    @get path, callback

  _readPoint: (query, callback) ->
    path = @path("db/#{@database}/series")
    path += "&q=" + encodeURIComponent(query)
    @get path, callback

  query: (query, callback) ->
    path  = @path("db/#{@database}/series")
    path += "&q=" + encodeURIComponent(query)
    @get(path, callback)

  get: (path, callback) ->
    new Promise (resolve, reject) =>
      @retry () =>
        $.getJSON @urlFor(path), (data) ->
          resolve(data)
          if callback
            callback formatPoints(data[0].points, data[0].columns)

  post: (path, params, callback) ->
    new Promise (resolve, reject) =>
      @retry () =>
        $.post @urlFor(path), params, (data) ->
          resolve(data)

  delete: (path, data) ->
    @retry () =>
      $.ajax type: "DELETE", url: @urlFor(path), data: data

  formatPoints: (points, columns) ->
    points.map (p) ->
      point = {}
      data[0].columns.forEach (column, index) ->
        point[column] = p[index]
      t = new Date(0)
      t.setUTCSeconds Math.round(point.time/1000)
      point.time = t
      point

  writePoint: (seriesName, values, options, callback) ->
    options ?= {}
    datum = {points: [], name: seriesName, columns: []}
    point = []

    for k, v of values
      point.push v
      datum.columns.push k

    datum.points.push point
    data = [datum]

    path  = @path("db/#{@database}/series")
    @post path, JSON.stringify(data), callback

  path: (action) ->
    "#{action}?u=#{@username}&p=#{@password}"

  url: (action) ->
    host = @hosts.shift();
    @hosts.push(host);
    "#{if @ssl then "https" else "http"}://#{host}:#{@port}/#{action}?u=#{@username}&p=#{@password}"

  urlFor: (path) ->
    host = @hosts.shift();
    @hosts.push(host);
    "#{if @ssl then "https" else "http"}://#{host}:#{@port}/#{path}"

  seriesUrl: (databaseName, query) ->
    @url("db/#{databaseName}/series")

  retry: (callback, delay, retries) ->
    delay ?= 10
    retries ?= @max_retries
    callback().then `undefined`, (reason) =>
      setTimeout () =>
        @retry callback, Math.min(delay * 2, 30000), retries-1
      , delay
