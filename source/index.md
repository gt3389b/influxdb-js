# InfluxDB JS Library

## Running the Jasmine Suite

This library has a built in test suite using Jasmine. To fire it up run:

```
bundle exec middleman start
```

Navigate to `http://localhost:4567/jasmine` and the suite will run in your browser.

## Releasing a New Version

First, update the internal version number in `data/influxdb.json` and then run:

```
bundle exec rake publish
```

This will build the assets using middleman and then deploy the versioned file to S3.
