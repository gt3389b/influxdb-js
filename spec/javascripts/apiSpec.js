describe("InfluxDB", function() {
  var api;
  var DATABASE = "influx.testdb";

  beforeEach(function() {
    influxdb = new InfluxDB();
    influxdb.deleteDatabase(DATABASE)
    successCallback = jasmine.createSpy("success");
  })

  describe("#url", function() {
    it("should build a properly formatted url", function() {
      var url = influxdb.url("foo")
      expect(url).toEqual("http://localhost:8086/foo?u=root&p=root")
    })
  })

  describe("#createDatabase", function() {
    it("should create a new database", function () {
      request = influxdb.createDatabase(DATABASE, successCallback)

      waitsFor(function() {
        return successCallback.callCount > 0;
      }, 100);

      runs(function() {
        expect(successCallback).toHaveBeenCalled();
      })
    })
  })

  describe("#readPoint", function() {
    it("should read a point from the database", function () {
      influxdb.readPoint()
    })
  })

  describe("#query", function() {

  })

  describe("#writePoint", function() {
    it("should write a point into the database", function () {
      influxdb.writePoint("foo", {a: 1, b: 2})
    })
  })
});
