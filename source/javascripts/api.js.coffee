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
    @isCrossOrigin = window.location.host not in @hosts

  ###
  # Databases
  #
  # GET    /db
  # POST   /db
  # DELETE /db/:db
  ###

  getDatabases: () ->
    @get @path("db")

  createDatabase: (databaseName, callback) ->
    data = {name: databaseName}
    @post @path("db"), data, callback

  deleteDatabase: (databaseName) ->
    @delete @path("db/#{databaseName}")

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
    @get @path("db/#{databaseName}/users")

  createUser: (databaseName, username, password, callback) ->
    data = {name: username, password: password}
    @post @path("db/#{databaseName}/users"), data, callback

  deleteDatabaseUser: (databaseName, username) ->
    @delete @path("db/#{databaseName}/users/#{username}")

  getDatabaseUser: (databaseName, username) ->
    @get @path("db/#{databaseName}/users/#{username}")

  updateDatabaseUser: (databaseName, username, params, callback) ->
    @post @path("db/#{databaseName}/users/#{username}"), params, callback

  authenticateDatabaseUser: () ->
    @get @path("db/#{@database}/authenticate")

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
    @get @path("cluster_admins")

  deleteClusterAdmin: (username) ->
    @delete @path("cluster_admins/#{username}")

  createClusterAdmin: (username, password, callback) ->
    data =
      name: username
      password: password

    @post @path("cluster_admins"), data

  updateClusterAdmin: (username, params, callback) ->
    @post @path("cluster_admins/#{username}"), params, callback

  authenticateClusterAdmin: (username, password, callback) ->
    @get @path("cluster_admins/authenticate")

  ###
  # Continuous Queries
  #
  # GET    /db/:db/continuous_queries
  # POST   /db/:db/continuous_queries
  # DELETE /db/:db/continuous_queries/:id
  ###

  getContinuousQueries: (databaseName) ->
    @get @path("db/#{databaseName}/continuous_queries")

  deleteContinuousQuery: (databaseName, id) ->
    @delete @path("db/#{databaseName}/continuous_queries/#{id}")

  ###
  # Cluster Servers & Shards
  #
  # GET    /cluster/servers
  # GET    /cluster/shards
  # POST   /cluster/shards
  # DELETE /cluster/shards/:id
  ###

  getClusterServers: () ->
    @get @path("cluster/servers")

  getClusterShards: () ->
    @get @path("cluster/shards")

  createClusterShard: (startTime, endTime, longTerm, serverIds, callback) ->
    data =
      startTime: startTime
      endTime: endTime
      longTerm: longTerm
      shards: [{serverIds: serverIds}]

    @post @path("cluster/shards"), data, callback

  deleteClusterShard: (id, serverIds) ->
    data =
      serverIds: serverIds

    @delete @path("cluster/shards/#{id}"), data

  ###
  # User Interfaces
  #
  # GET /interfaces
  ###

  getInterfaces: () ->
    @get @path("interfaces")

  readPoint: (fieldNames, seriesNames, callback) ->
    query = "SELECT #{fieldNames} FROM #{seriesNames};"
    @get @path("db/#{@database}/series", {q: query}), callback

  _readPoint: (query, callback) ->
    @get @path("db/#{@database}/series", {q: query}), callback

  query: (query, callback) ->
    @get @path("db/#{@database}/series", {q: query}), callback

  get: (path, callback) ->
    new Promise (resolve, reject) =>
      @retry resolve, reject, () =>
        reqwest(
          method: 'get'
          type: 'json'
          url: @url(path)
          crossOrigin: @isCrossOrigin
          success: (data) =>
            resolve(data)
            callback @formatPoints(data) if callback
        )

  post: (path, data, callback) ->
    new Promise (resolve, reject) =>
      @retry resolve, reject, () =>
        reqwest(
          method: 'post'
          type: 'json'
          url: @url(path)
          crossOrigin: @isCrossOrigin
          contentType: 'application/json'
          data: JSON.stringify(data)
          success: (data) ->
            resolve(data)
        )


  delete: (path, data) ->
    new Promise (resolve, reject) =>
      @retry resolve, reject, () =>
        reqwest(
          method: 'delete'
          type: 'json'
          url: @url(path)
          crossOrigin: @isCrossOrigin
          data: JSON.stringify(data)
          success: (data) ->
            resolve(data)
            callback(data) if callback?
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
    @post @path("db/#{@database}/series"), data, callback

  path: (action, opts) ->
    path  = "#{action}?u=#{@username}&p=#{@password}"
    path += "&q=" + encodeURIComponent(opts.q) if opts? and opts.q
    path

  url: (path) ->
    host = @hosts.shift();
    @hosts.push(host);
    "#{if @ssl then "https" else "http"}://#{host}:#{@port}/#{path}"

  retry: (resolve, reject, callback, delay, retries) ->
    delay ?= 10
    retries ?= @max_retries
    callback().then `undefined`, (reason) =>
      if reason.status == 0
        setTimeout () =>
          @retry resolve, reject, callback, Math.min(delay * 2, 30000), retries - 1
        , delay
      else
        reject(reason)
