# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter [mysql1](https://pub.dev/packages/mysql1) plugin util, Use mysql1 easily.

[简体中文](README_ZH.md)

### Pub

```yaml
dependencies:
  mysql_utils: ^1.0.2
```

### APIs

#### Initialization connection

```yaml
 var db = MysqlUtils(
  settings: ConnectionSettings(
    host: '127.0.0.1',
    port: 3306,
    user: 'user',
    password: 'password',
    db: 'db',
    useCompression: false,
    useSSL: false,
    timeout: const Duration(seconds: 10),
  ),
  prefix: 'prefix_',
  pool: true,
  errorLog: (error) {
    print('|$error\n├───────────────────────────');
  },
  sqlLog: (sql) {
    print('|$sql\n├───────────────────────────');
  },
  connectInit: (db1) async {
    print('whenComplete');
  }
);
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
  //limit: 10,//limit(10) or limit('10 ,100')
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
  //limit: 10,//limit(10) or limit('10 ,100')
  where: {'email': 'xxx@google.com','id': ['between', '1,4'],'email': ['=', 'sss@google.com'],'news_title': ['like', '%name%'],'user_id': ['>', 1]},
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
        'email': 'biner@dd.com'
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
    'email': 'biner@dd.com'
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
  //debug: false,
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

#### createConnection

Create a new connection

```yaml
var newDb = await db.createConnection();
```
