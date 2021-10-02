import 'dart:async';

import 'package:mysql_utils/mysql_utils.dart';

Future main() async {
  final db = MysqlUtils(
      settings: ConnectionSettings(
        host: '127.0.0.1',
        port: 3306,
        user: 'test',
        password: 'test',
        db: 'database',
        useCompression: false,
        useSSL: false,
        timeout: const Duration(seconds: 10),
      ),
      prefix: '',
      pool: true,
      errorLog: (error) {
        print('|$error\n├───────────────────────────');
      },
      sqlLog: (sql) {
        print('|$sql\n├───────────────────────────');
      },
      connectInit: (db1) async {
        print('whenComplete');
        // var row = await db1.getOne(
        //   table: 'su_user',
        //   fields: '*',
        //   where: {'id': 1},
        // );
        // print(row);
      });

  //////insert
  ///
  // var res = await db.insert(
  //   table: 'su_user',
  //   insertData: {
  //     'telphone': '+113888888888',
  //     'create_time': 1620577162252,
  //     'update_time': 1620577162252,
  //   },
  // );
  // print(res);
  // var isAlive = await db.isConnectionAlive();
  // if (isAlive) {
  //   print('mysql is isAlive');
  // }
  //////getOne
  ///
  // var row = await db.getOne(
  //   table: 'su_user',
  //   fields: '*',
  //   where: {'id': 1},
  // );
  // print(row);
  //////getAll

  var row2 = await db.getAll(
    table: 'table',
    fields: '*',
    where: {
      // 'email': 'xxx@google.com',
      // 'id': ['between', 0, 1],
      // 'id': ['notbetween', 0, 2],
      // 'email2': ['=', 'sss@google.com'],
      // 'news_title': ['like', '%name%'],
      'id': ['>', 1],
      // 'id': ['in', [1,2,3]]
    },
    debug: true,
  );
  print(row2);
  //////avg
  ///
  // var row = await db.avg(
  //   table: 'Product',
  //   fields: 'price',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row);
  //////min
  ///
  //   var row = await db.min(
  //     table: 'Product',
  //     fields: 'price',
  //     where: {
  //       'id': ['>', 0]
  //     },
  //     debug: true,
  //   );
  //   print(row);
  //////max
  ///
  // var row = await db.max(
  //   table: 'Product',
  //   fields: 'price',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row);
  ////// base sql
  ///
  // var row = await db
  //     .query('SELECT * FROM Product1 as a,Product2 as b WHERE a.id = b.id', []);
  // print(row);

  // var row2 = await db.getAll(
  //   table: 'table',
  //   fields: '*',
  //   where: {
  //     // 'price': ['>', 0],
  //     // 'id': ['between', 0, 1],
  //     // 'id': ['notbetween', 0, 2],
  //     // 'id': [
  //     //   'in',
  //     //   [1, 2]
  //     // ],
  //   },
  //   debug: true,
  // );
  // print(row2);
}
