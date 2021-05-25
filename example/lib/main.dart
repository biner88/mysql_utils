import 'dart:async';

import 'package:mysql1/mysql1.dart';
import 'package:mysql_utils/mysql_utils.dart';

Future main() async {
  final db = MysqlUtils(
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

  ///Service mode
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
  var row = await db.getOne(
    table: 'su_user',
    fields: '*',
    where: {'id': 1},
  );
  print(row);

  // var row2 = await db.getAll(
  //   table: 'table',
  //   fields: '*',
  //   where: {
  //     'email': 'xxx@google.com',
  //     'id': ['between', '1,4'],
  //     'email2': ['=', 'sss@google.com'],
  //     'news_title': ['like', '%name%'],
  //     'user_id': ['>', 1]
  //   },
  //   debug: true,
  // );
  // print(row2);
}
