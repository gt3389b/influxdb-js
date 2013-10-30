#= require vendor/jquery-2.0.3
#= require vendor/angular
#= require influxdb
#= require play
#= require_self

playApp = angular.module "playApp", []

playApp.controller "PlayCtrl", ["$scope", "$location", "$q", ($scope, $location, $q) ->
  $scope.host = "ec2-23-20-52-199.compute-1.amazonaws.com"
  $scope.port = 9061
  # $scope.host = "localhost"
  # $scope.port = 8086
  $scope.username = null
  $scope.password = null
  $scope.databaseName = null
  $scope.databaseCreated = false

  influx = new InfluxDB($scope.host, $scope.port, "root", "root")

  $scope.createDatabase = () ->
    return unless $scope.databaseName
    $q.when(influx.createDatabase($scope.databaseName)).then (response) ->
      $scope.username = $scope.generateCode(8)
      $scope.password = $scope.generateCode(12)
      $q.when(influx.createUser($scope.databaseName, $scope.username, $scope.password)).then (response) ->
        $scope.databaseCreated = true

  $scope.getDatabaseNames = () ->
    $q.when(master.getDatabaseNames()).then (response) ->
      $scope.databases = JSON.parse(response)

  $scope.generateCode = (length) ->
    Array.apply(0, Array(length)).map(->
      ((charset) ->
        charset.charAt Math.floor(Math.random() * charset.length)
      ) "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    ).join ""


  $scope.success = (msg) ->
    $scope.successMessage = msg
    $("span#writeSuccess").show().delay(1500).fadeOut(500);
]
