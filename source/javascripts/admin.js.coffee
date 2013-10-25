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
  influx = null

  console.log $scope.username

  $scope.authenticate = () ->
    influx = new InfluxDB($scope.host, $scope.port, $scope.username, $scope.password)
    $scope.authenticated = true

  $scope.writeDataTest = () ->
    $q.when(influx.writePoint("foo", {a:1, b:2})).then (response) ->

  $scope.readDataTest = () ->
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
