# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter [mysql1](https://pub.dev/packages/mysql1) plugin 帮助扩展类.

[English](README.md)

### Pub

```yaml
dependencies:
  mysql_utils: ^1.0.2
```

### APIs

#### 初始化连接

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
`

#### query

原生查询

```yaml
var row = await db
    .query('select id from Product where id=? or description like ?', [1, 'ce%']);
print(row);
`````

#### getOne

查询一条数据

```yaml
var row = await db.getOne(
  table: 'table',
  fields: '*',
  //group: 'name',
  //having: 'name',
  //order: 'id desc',
  //limit: 10,//10 or '10 ,100'
  where: {'email': 'xxx@dd.com'},
);
print(row);
```

#### getAll

查询多条数据

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
    //'id': ['notbetween', '1,4'],
    //'id': ['between', '1,4'],
    //'id': ['in', [1,2,3]],
    //'email': ['=', 'sss@cc.com'],
    //'news_title': ['like', '%name%'],
    //'user_id': ['>', 1],
    
  },
);
print(row);
```

#### insert 

增加一条数据

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

增加多条数据

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

更新数据

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

删除数据

```yaml
await db.delete(
  table:'table',
  where: {'id':1}
);
```

#### count

统计数据

```yaml
await db.count(
  table: 'table',
  fields: '*',
  //group: 'name',
  //having: 'name',
  //debug: false,
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

事务支持

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

连接是否关闭

```yaml
var isAlive = await db.isConnectionAlive();
if (isAlive) print('mysql is isAlive');
```

#### createConnection

创建新连接

```yaml
var newDb = await db.createConnection();
```
