adminApp = angular.module "adminApp", []

adminApp.controller "AdminIndexCtrl", ["$scope", "$location", "$q", ($scope, $location, $q) ->
  $scope.host = $location.search()["host"] || $location.host()
  $scope.port = $location.search()["port"] || if $scope.host == "sandbox.influxdb.org" then 9061 else 8086
  $scope.database = $location.search()["database"]
  $scope.username = $location.search()["username"]
  $scope.password = $location.search()["password"]
  $scope.authenticated = false
  $scope.data = []
  $scope.readQuery = null
  $scope.writeSeriesName = null
  $scope.writeValues = null
  $scope.successMessage = "OK"
  $scope.alertMessage = "Error"
  $scope.authMessage = ""
  influx = null
  master = null

  master = new InfluxDB($scope.host, $scope.port, "root", "root")

  $scope.authenticate = () ->
    influx = new InfluxDB($scope.host, $scope.port, $scope.username, $scope.password, $scope.database)
    $q.when(influx._readPoint("SELECT * FROM _foobar.bazquux_;")).then (response) ->
      console.log response
      $scope.authenticated = true
      $location.search({})
    , (response) ->
      $scope.authError(response.responseText)

  $scope.getDatabaseNames = () ->
    $q.when(master.getDatabaseNames()).then (response) ->
      $scope.databases = JSON.parse(response)

  $scope.writeData = () ->
    unless $scope.writeSeriesName
      $scope.error("Time Series Name is required.")
      return

    try
      values = JSON.parse($scope.writeValues)
    catch
      $scope.alertMessage = "Unable to parse JSON."
      $("span#writeFailure").show().delay(1500).fadeOut(500);
      return

    $q.when(influx.writePoint($scope.writeSeriesName, values)).then (response) ->
      $scope.success("200 OK")

  $scope.readData = () ->
    $scope.data = []

    $q.when(influx._readPoint($scope.readQuery)).then (response) ->
      data = JSON.parse(response)
      data.forEach (datum) ->
        $scope.data.push
          name: datum.name
          columns: datum.columns
          points: datum.points

  $scope.authError = (msg) ->
    $scope.authMessage = msg
    $("span#authFailure").show().delay(1500).fadeOut(500);

  $scope.error = (msg) ->
    $scope.alertMessage = msg
    $("span#writeFailure").show().delay(1500).fadeOut(500);

  $scope.success = (msg) ->
    $scope.successMessage = msg
    $("span#writeSuccess").show().delay(1500).fadeOut(500);

  if $scope.username && $scope.password && $scope.database
    $scope.authenticate()
]
