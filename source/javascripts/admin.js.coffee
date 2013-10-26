adminApp = angular.module "adminApp", []

adminApp.controller "AdminIndexCtrl", ["$scope", "$location", "$q", ($scope, $location, $q) ->
  $scope.host = "localhost"
  $scope.port = 8086
  $scope.username = "user"
  $scope.password = "pass"
  $scope.authenticated = true
  $scope.data = []
  $scope.readQuery = null
  $scope.writeSeriesName = null
  $scope.writeValues = null
  $scope.successMessage = "OK"
  $scope.alertMessage = "Error"
  influx = null

  $scope.authenticate = () ->
    influx = new InfluxDB($scope.host, $scope.port, $scope.username, $scope.password)
    $scope.authenticated = true

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

  $scope.error = (msg) ->
    $scope.alertMessage = msg
    $("span#writeFailure").show().delay(1500).fadeOut(500);

  $scope.success = (msg) ->
    $scope.successMessage = msg
    $("span#writeSuccess").show().delay(1500).fadeOut(500);

  $scope.authenticate()
]
