adminApp = angular.module "adminApp", []

adminApp.controller "AdminIndexCtrl", ["$scope", "$location", "$q", ($scope, $location, $q) ->
  $scope.host = "localhost"
  $scope.port = 8086
  $scope.username = "root"
  $scope.password = "root"
  $scope.authenticated = true
  $scope.data = []
  $scope.columns = []
  $scope.points = []
  $scope.readQuery = null
  $scope.writeSeriesName = null
  $scope.writeValues = null
  $scope.successMessage = "OK"
  $scope.alertMessage = "Error"
  influx = null

  console.log $scope.username

  $scope.authenticate = () ->
    influx = new InfluxDB($scope.host, $scope.port, $scope.username, $scope.password)
    $scope.authenticated = true

  $scope.writeData = () ->
    unless $scope.writeSeriesName
      $scope.alertMessage = "Time Series Name is required."
      $("span#writeFailure").show().delay(1500).fadeOut(500);
      return


    try
      values = JSON.parse($scope.writeValues)
    catch
      $scope.alertMessage = "Unable to parse JSON."
      $("span#writeFailure").show().delay(1500).fadeOut(500);
      return

    $q.when(influx.writePoint($scope.writeSeriesName, values)).then (response) ->
      $scope.successMessage = "200 OK"
      $("span#writeSuccess").show().delay(1500).fadeOut(500);

  $scope.readData = () ->
    $q.when(influx._readPoint($scope.readQuery)).then (response) ->
      $scope.data = JSON.parse(response)
      console.log $scope.data
      if $scope.data.length == 0
        $scope.columns = []
        $scope.points = []
      else
        $scope.columns = $scope.data[0].columns
        $scope.points = $scope.data[0].points

  $scope.authenticate()
]
