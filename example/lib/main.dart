import 'dart:async';

import 'package:mysql_utils/mysql1/mysql1.dart';
import 'package:mysql_utils/mysql_utils.dart';

Future main() async {
  final db = MysqlUtils(
      settings: ConnectionSettings(
        host: '10.0.0.88',
        port: 3306,
        user: 'mysqltest',
        password: 'mysqltest',
        db: 'mysqltest',
        useCompression: false,
        useSSL: false,
        timeout: const Duration(seconds: 10),
      ),
      prefix: 'su_',
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
  ////
  // var res = await db.getAll(
  //   table: 'user tb1,upload tb2',
  //   fields: 'tb2.fileSize',
  //   where: 'tb2.id>0 and tb2.uid=tb1.id',
  //   debug: true,
  // );
  // print(res);
  //////insert
  ///
  // var res = await db.insert(
  //   table: 'user',
  //   insertData: {
  //     'nickname': 'biner',
  //     'telphone': '+113888888888',
  //     'createTime': 1620577162252,
  //     'updateTime': 1620577162252,
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

  // var row2 = await db.getAll(
  //   table: 'user',
  //   fields: '*',
  //   where: {
  //     // 'email': 'xxx@google.com',
  //     // 'id': ['between', '1,4'],
  //     //'id': ['notbetween', '1,4'],
  //     // 'email2': ['=', 'sss@google.com'],
  //     // 'news_title': ['like', '%name%'],
  //     'id': ['>', 1],
  //     // 'id': ['in', [1,2,3]]
  //   },
  //   debug: true,
  // );
  // print(row2);
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
