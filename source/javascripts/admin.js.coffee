adminApp = angular.module "adminApp", []

adminApp.controller "AdminIndexCtrl", ["$scope", "$location", "$q", ($scope, $location, $q) ->
  $scope.host = "localhost"
  $scope.port = 8086
  $scope.username = "root"
  $scope.password = "root"
  $scope.authenticated = true
  $scope.columns = []
  $scope.points = []
  influx = null

  console.log $scope.username

  $scope.authenticate = () ->
    influx = new InfluxDB($scope.host, $scope.port, $scope.username, $scope.password)
    $scope.authenticated = true

  $scope.writeDataTest = () ->
    $q.when(influx.writePoint("foo", {a:1, b:2})).then (response) ->

  $scope.readDataTest = () ->
    $q.when(influx.readPoint("foo")).then (response) ->
      data = JSON.parse(response)
      $scope.columns = data[0].columns
      $scope.points = data[0].points
      console.log(data)

  $scope.authenticate()

  # $scope.writeDataTest()

]
