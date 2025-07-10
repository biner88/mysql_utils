# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter mysql plugin helps extend classes.

mysql_client has been abandoned and is now maintained by the author of this library. The new library is [mysql_client_plus](https://pub.dev/packages/mysql_client_plus) [![Pub](https://img.shields.io/pub/v/mysql_client_plus.svg)](https://pub.dev/packages/mysql_client_plus)。

If you use sqlite, you can also try [sqlite_utils](https://pub.dev/packages/sqlite_utils).

[简体中文](README_ZH.md)

### Pub install

[Install](https://pub.dev/packages/mysql_utils/install)

## New features [2.1.7] 

* Updated mysql_client_plus to version ^0.0.32
* Updated settings from `Map` to `MysqlUtilsSettings` ⚠️⚠️⚠️
* Added support for `BLOB` and `JSON` types
* Added support for SSL certificates
* Added support for calling stored procedures
* Added support for `sha256_password` authentication
* Added global `debug` option
* Added tests

### APIs

#### Initialization connection

Use the singleton mode, and call `close()` after use to close the database connection.

```dart
 var db = MysqlUtils(
  // ⚠️⚠️⚠️ settings from `Map` to `MysqlUtilsSettings`
  settings: MysqlUtilsSettings(
    // The hostname of the MySQL server, defaults to localhost.
    host: '127.0.0.1',
    // The port number to connect to, defaults to 3306.
    port: 3306,
    // The username to connect as, defaults to root.
    user: 'your_user_sha256',
    // The password to connect with, defaults to empty string.
    password: 'your_password_sha256',
    // The database to use, defaults to empty string.
    db: 'testdb',
    // Whether to use SSL, defaults to false.
    secure: true,
    // The prefix to use for table names, defaults to empty string.
    prefix: '',
    // The maximum number of connections to keep open, defaults to 1000.
    maxConnections: 1000,
    // The timeout in milliseconds for each connection, defaults to 10000.
    timeoutMs: 10000,
    // Whether to escape all queries, defaults to true.
    sqlEscape: true,
    // Whether to use a connection pool, defaults to false.
    pool: true,
    // The collation to use for all queries, defaults to utf8mb4_general_ci.
    collation: 'utf8mb4_general_ci',
    // Whether to use SSL, defaults to false.
    debug: true,
    // The SSL options to use for all queries, defaults to null.
    // securityContext: SecurityContext(),
    // sslMode: SslMode.require,
    // onBadCertificate: (certificate) => true,
  ),
  errorLog: (error) {
    print(error);
  },
  sqlLog: (sql) {
    print(sql);
  },
  connectInit: (db1) async {
    print('whenComplete');
  }
);
```

#### query

Native query

```dart
//var row = await db.query('select id from test_data2 where id=? or string_column like ?', whereValues: [1, '%串%'], isStmt: true);
var row = await db.query("select id from test_data2 where id=1 or string_column like '%mysql%'");
print(row.toMap());
print(row.toMap());
//// print(row.rowsAssoc.first.assoc());
// for (var item in row.rowsAssoc) {
//   print(item.assoc());
// }
// for (final row in row.rowsAssoc) {
//   print(row.colAt(0));
//   print(row.colByName("nickname"));
//   print(row.assoc());
// }
// db.close();
```

#### Multi table query

Query Multi data , multi-table query

```dart
var res = await db.getAll(
  table: 'user tb1,upload tb2',
  fields: 'tb2.fileSize',
  where: 'tb2.id>0 and tb2.uid=tb1.id',
  debug: true,
);
print(res);
```

#### getOne

Query one data

```dart
var row = await db.getOne(
  table: 'table',
  fields: '*',
  //excludeFields: 'telphone,image',
  //group: 'name',
  //having: 'name',
  //order: 'id desc',
  //limit: 10,//10 or '10 ,100'
//   where: {
//     'email': 'xxx@google.com',
//     'id': ['between', '1,4'],
//     'email2': ['=', 'sss@google.com'],
//     'news_title': ['like', '%name%'],
//     'user_id': ['>', 1],
//     'user_id': ['<', 1],
//     'user_id': ['<>', 1],
//     'user_id': ['=', 1],
//     'email3': ['!=', 'sss@google.com'],
//     '_SQL': '(`isNet`=1 OR `isNet`=2)',
//   },
  //where:'`id`=1 AND name like "%jame%"',
);
print(row);
```

#### getAll

Query multiple data

```dart

var row = await db.getAll(
  table: 'table',
  fields: '*',
  //excludeFields: 'telphone,image',
  //group: 'name',
  //having: 'name',
  //order: 'id desc',
  //limit: 10,//10 or '10 ,100'
//   where: {
//     'email': 'xxx@google.com',
//     'id': ['between', '1,4'],
//     'email2': ['=', 'sss@google.com'],
//     'news_title': ['like', '%name%'],
//     'user_id': ['>', 1],
//     '_SQL': '(`isNet`=1 OR `isNet`=2)',
//   },
  //where:'`id`=1 AND name like "%jame%"',
);
print(row);
```

#### insert

Add a data, return lastInsertID.

```dart
await db.insert(
  table: 'table',
  debug: false,
  insertData: {
    'telphone': '+113888888888',
    'email': 'teenagex@dd.com',
    'blob_data':Uint8List.fromList([0x48, 0x65, 0x6c, 0x6c, 0x6f]),
    'json_data':'{"name": "MysqlUtils"}',
    'date_data': '2025-01-01',
    'create_time': 1620577162252,
    'update_time': 1620577162252,
  },
);
```

#### insertAll

Add multiple data, return affectedRows.

```dart
 await db.insertAll(
  table: 'table',
  debug: false,
  insertData: [
      {
        'telphone': '13888888888',
        'create_time': 1111111,
        'update_time': 12121212,
        'email': 'teenagex@dd.com'
      },
      {
        'telphone': '13881231238',
        'create_time': 324234,
        'update_time': 898981,
        'email': 'xxx@dd.com'
      }
]);

```

#### update

Update data

```dart
await db.update(
  table: 'table',
  updateData:{
    'telphone': '1231',
    'create_time': 12,
    'update_time': 12121212,
    'email': 'teenagex@dd.com',
    'view_count': ['inc', 1], //or ['+', 1], 
    'first_view': ['dec', 1]  //or ['-', 1], 
  },
  where:{
  'id':1,
});
// update table set telphone='1231',create_time=12,update_time=12121212,email='teenagex@dd.com',view_count=view_count+1,first_view=first_view-1 where id=1;
```

#### delete

Delete data

```dart
await db.delete(
  table:'table',
  where: {'id':1}
);
```

#### count

Statistical data

```dart
await db.count(
  table: 'table',
  fields: '*',
  //group: 'name',
  //having: 'name',
);
```

#### avg

```dart
await db.avg(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### min

```dart
await db.min(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### max

```dart
await db.max(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### Transaction

Transaction support, In case of exception, transaction will roll back automatically.

```dart
await db.startTrans();
await db.delete(table: 'user', where: {'id': 25}, debug: true);
//await db.delete(table: 'user1', where: {'id': 26}, debug: true);
await db.commit();
await db.close();
```

#### isConnectionAlive

Connection is open or closed

```dart
var isAlive = await db.isConnectionAlive();
if (isAlive) print('mysql is isAlive');
```

#### Test

```shell
dart test
```
