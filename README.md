# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter mysql plugin helps extend classes.
Since 2.0.0, the mysql_client extension library is used, which is more stable.
Try to be compatible with the method before version 2.0.0.

[简体中文](README_ZH.md)

### Pub install

[Install](https://pub.dev/packages/mysql_utils/install)

### APIs

#### Initialization connection

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
    'collation': 'utf8mb4_general_ci',
  },
  prefix: 'prefix_',
  pool: true,
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

```yaml
var row = await db
    .query('select id from Product where id=? or description like ?', [1, 'ce%']);
print(row.rows.first.assoc());
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
  //where: 'email=xxx@google.com',
  where: {'email': 'xxx@google.com'},
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
  where: {
    'email': 'xxx@dd.com',
    //'id': ['between', 0, 1],
    //'id': ['notbetween', 0, 2],
    //'id': ['in', [1,2,3]],
    //'id': ['notin', [1,2,3]],
    //'email': ['=', 'sss@cc.com'],
    //'news_title': ['like', '%name%'],
    //'user_id': ['>', 1],
  },
);
print(row);
```

#### insert

Add a data

```yaml
await db.insert(
  table: 'table',
  insertData: {
    'telphone': '+113888888888',
    'create_time': 1620577162252,
    'update_time': 1620577162252,
  },
);
```

#### insertAll

Add multiple data

```yaml
 await db.insertAll(
  table: 'table',
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

Transaction support

```yaml
await db.startTrans();
var res1 = await db.delete(
  table:'table',
  where: {'id':1}
);
if(res1>0){
  await db.commit();
}else{
  await db.rollback();
}
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
