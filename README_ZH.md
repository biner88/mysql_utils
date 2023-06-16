# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter mysql plugin 帮助扩展类.
从2.0.0开始使用mysql_client扩展库，更稳定。
尽量兼容2.0.0以前版本方法。
如果您使用sqlite，也可以尝试下 [sqlite_utils](https://pub.dev/packages/sqlite_utils).

[English](README.md)

### 安装方法

[Install](https://pub.dev/packages/mysql_utils/install)

### APIs

#### 初始化连接

相比1.0，初始化参数有变化，请参照以下修改，使用单例模式，使用完请调用 close(); 关闭数据库连接。

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
    'pool': false,
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
`

#### query

原生查询，注意这里和1.0版使用方式不一样，2.0继承了mysql_client的方法

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

#### 多表查询

多表查询

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

增加一条数据，返回新增的ID

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

增加多条数据, 返回影响的记录数

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

事务支持, 发生错误自动回滚

```yaml
await db.startTrans();
await db.delete(table: 'user', where: {'id': 25}, debug: true);
//await db.delete(table: 'user1', where: {'id': 26}, debug: true);
await db.commit();
await db.close();
```

#### isConnectionAlive

连接是否关闭

```yaml
var isAlive = await db.isConnectionAlive();
if (isAlive) print('mysql is isAlive');
```
