# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter mysql plugin helps extend classes.
Since 2.0.0, the mysql_client extension library is used, which is more stable.
Try to be compatible with the method before version 2.0.0.

If you use sqlite, you can also try [sqlite_utils](https://pub.dev/packages/sqlite_utils).

[简体中文](README_ZH.md)

### Pub install

[Install](https://pub.dev/packages/mysql_utils/install)

### APIs

#### Initialization connection

Compared with 1.0, the initialization parameters have changed. Please refer to the following modifications, use the singleton mode, and call close(); after use to close the database connection.

```yaml
 var db = MysqlUtils(
  settings: {
    'host': '127.0.0.1',
    'port': 3306,
    'user': 'root',
    'password': 'root',
    'db': 'test',
    'maxConnections': 10,
    'secure': false,
    'prefix': 'prefix_',
    'pool': true,
    'collation': 'utf8mb4_general_ci',
    'sqlEscape': true,
  },
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

Native query, note that the usage here is different from version 1.0, 2.0 inherits the method of mysql_client

```yaml
var row = await db
    .query('select id from Product where id=:id or description like :description',{
      'id':1,
      'description':'%ce%'
    });
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
`````

#### getAll(getOne) Multi table

Query Multi data , multi-table query

```yaml
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

```yaml
var row = await db.getOne(
  table: 'table',
  fields: '*',
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

```yaml

var row = await db.getAll(
  table: 'table',
  fields: '*',
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

```yaml
await db.insert(
  table: 'table',
  debug: false,
  insertData: {
    'telphone': '+113888888888',
    'create_time': 1620577162252,
    'update_time': 1620577162252,
  },
);
```

#### insertAll

Add multiple data, return affectedRows.

```yaml
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

```yaml
await db.update(
  table: 'table',
  updateData:{
    'telphone': '1231',
    'create_time': 12,
    'update_time': 12121212,
    'email': 'teenagex@dd.com'
  },
  where:{
  'id':1,
});
```

#### delete

Delete data

```yaml
await db.delete(
  table:'table',
  where: {'id':1}
);
```

#### count

Statistical data

```yaml
await db.count(
  table: 'table',
  fields: '*',
  //group: 'name',
  //having: 'name',
);
```

#### avg

```yaml
await db.avg(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### min

```yaml
await db.min(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### max

```yaml
await db.max(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### Transaction

Transaction support, In case of exception, transaction will roll back automatically.

```yaml
await db.startTrans();
await db.delete(table: 'user', where: {'id': 25}, debug: true);
//await db.delete(table: 'user1', where: {'id': 26}, debug: true);
await db.commit();
await db.close();
```

#### isConnectionAlive

Connection is open or closed

```yaml
var isAlive = await db.isConnectionAlive();
if (isAlive) print('mysql is isAlive');
```

#### demo test

```
cd example
dart run lib/main.dart
```
