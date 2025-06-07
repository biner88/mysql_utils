# mysql_utils

[![Pub](https://img.shields.io/pub/v/mysql_utils.svg)](https://pub.dev/packages/mysql_utils)

Flutter mysql plugin 帮助扩展类.

mysql_client 已放弃维护，现在由本库作者继续维护，新库是 [mysql_client_plus](https://pub.dev/packages/mysql_client_plus) [![Pub](https://img.shields.io/pub/v/mysql_client_plus.svg)](https://pub.dev/packages/mysql_client_plus)。

如果您使用sqlite，也可以尝试下 [sqlite_utils](https://pub.dev/packages/sqlite_utils) .

[English](README.md)

### 安装方法

[Install](https://pub.dev/packages/mysql_utils/install)

### APIs

#### 初始化连接

使用单例模式，使用完请调用 `close()` 关闭数据库连接。

```dart
 var db = MysqlUtils(
  settings: MysqlUtilsSettings(
    // 配置数据库连接信息
    host: '127.0.0.1',
    // 端口
    port: 3306,
    // 数据库用户名
    user: 'your_user',
    // 数据库密码
    password: 'your_password',
    // 数据库名称
    db: 'testdb',
    // 是否使用SSL
    secure: true,
    // 表前缀
    prefix: '',
    // 最大连接数
    maxConnections: 1000,
    // 连接超时
    timeoutMs: 10000,
    // 是否使用SQL转义
    sqlEscape: true,
    // 是否使用连接池
    pool: true,
    // 字符编码
    collation: 'utf8mb4_general_ci',
    // 是否开启debug
    debug: true,
    // 是否使用SSL
    // securityContext: SecurityContext(),
    // SSL证书
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
`

#### query

原生查询

```dart
//var row = await db.query('select id from test_data2 where id=? or string_column like ?', whereValues: [1, '%串%'], isStmt: true);
var row = await db.query("select id from test_data2 where id=1 or string_column like '%串%'");
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

查询一条数据

```dart
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

查询多条数据

```dart

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

增加一条数据，返回新增的ID

```dart
await db.insert(
  table: 'table',  
  debug: false,
  insertData: {
    'telphone': '+113888888888',
    'blob_data':Uint8List.fromList([0x48, 0x65, 0x6c, 0x6c, 0x6f]),
    'json_data':'{"name": "MysqlUtils"}',
    'date_data': '2025-01-01',
    'create_time': 1620577162252,
    'update_time': 1620577162252,
  },
);
```

#### insertAll

增加多条数据, 返回影响的记录数

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

更新数据

```dart
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

```dart
await db.delete(
  table:'table',
  where: {'id':1}
);
```

#### count

统计数据记录数

```dart
await db.count(
  table: 'table',
  fields: '*',
  //group: 'name',
  //having: 'name',
  //debug: false,
);
```

#### avg

获取指定字段的平均值

```dart
await db.avg(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### min

获取指定字段的最小值

```dart
await db.min(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### max

获取指定字段的最大值

```dart
await db.max(
  table: 'table',
  fields: 'price',
  //group: 'name',
  //having: 'name',
);
```

#### Transaction

事务支持, 发生错误自动回滚

```dart
await db.startTrans();
await db.delete(table: 'user', where: {'id': 25}, debug: true);
//await db.delete(table: 'user1', where: {'id': 26}, debug: true);
await db.commit();
await db.close();
```

#### isConnectionAlive

连接是否关闭

```dart
var isAlive = await db.isConnectionAlive();
if (isAlive) print('mysql is isAlive');
```
