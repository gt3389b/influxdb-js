Create a new InfluxDB object with

```
new InfluxDB(opts)
```

where opts is an object with these keys:

- `database`
- `host` (default: `"localhost"`)
- `hosts` (default: `[host]`)
- `port` (default: `8086`),
- `username` (default: `"root"`)
- `password` (default: `"root"`)
- `ssl` (default: `false`)
- `max_retries` (default: `20`)


InfluxDB object have these methods:

- `getDatabases: ()`

- `createDatabase: (databaseName, callback)`

- `deleteDatabase: (databaseName)`

- `getClusterConfiguration: ()`

- `createDatabaseConfig: (databaseName, data, callback)`

- `getDatabaseUsers: (databaseName)`

- `createUser: (databaseName, username, password, callback)`

- `deleteDatabaseUser: (databaseName, username)`

- `getDatabaseUser: (databaseName, username)`

- `updateDatabaseUser: (databaseName, username, params, callback)`

- `authenticateDatabaseUser: ()`

- `getClusterAdmins: ()`

- `deleteClusterAdmin: (username)`

- `createClusterAdmin: (username, password, callback)`

- `updateClusterAdmin: (username, params, callback)`

- `authenticateClusterAdmin: (username, password, callback)`

- `getContinuousQueries: (databaseName)`

- `deleteContinuousQuery: (databaseName, id)`

- `getClusterServers: ()`

- `getClusterShardSpaces: ()`

- `getClusterShards: ()`

- `createClusterShard: (startTime, endTime, database, spaceName, serverIds, callback)`

- `deleteClusterShard: (id, serverIds)`

- `getInterfaces: ()`

- `readPoint: (fieldNames, seriesNames, callback)`

- `query: (query, callback)`

- `writePoint: (seriesName, values, options, callback)`

- `writeSeries: (seriesData, callback)`
