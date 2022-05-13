import 'dart:async';
import 'dart:math';

import 'package:mysql_utils/mysql_utils.dart';

Future main() async {
  var rng = new Random();
  final db = MysqlUtils(
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
    prefix: 'su_',
    pool: true,
    errorLog: (error) {
      print(error);
    },
    sqlLog: (sql) {
      print(sql);
    },
    connectInit: (db1) async {
      print('whenComplete');
    },
  );
  //////getOne
  var row1 = await db.getOne(
    table: 'user',
    fields: '*',
    where: {'id': 2},
    debug: true,
  );
  print(row1); //Map
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
  // print(row2); //List<Map>
  //////insert
  // var res3 = await db.insert(
  //   table: 'user',
  //   insertData: {
  //     'nickname': 'biner',
  //     'telphone': '+113888888888',
  //     'createTime': 1620577162252,
  //     'updateTime': 1620577162252,
  //   },
  // );
  // print(res3); //lastInsertID
  ////getAll, Multi table
  // var res4 = await db.getAll(
  //   table: 'user tb1,name tb2',
  //   fields: 'tb2.name',
  //   where: 'tb2.id>0 and tb2.id=tb1.id',
  //   debug: true,
  // );
  // print(res4); //[{name: hh}, {name: joy}]
  //////count'
  // var row5 = await db.count(
  //   table: 'user',
  //   fields: 'nickname',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row5);

  //////avg
  // var row = await db.avg(
  //   table: 'user',
  //   fields: 'id',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row);
  ////min
  // var row = await db.min(
  //   table: 'user',
  //   fields: 'id',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row);
  //////max
  // var row = await db.max(
  //   table: 'user',
  //   fields: 'id',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row);
  //////delete
  // var row = await db.delete(
  //   table: 'user',
  //   where: {
  //     'id': ['=', 1]
  //   },
  //   debug: true,
  // );
  // print(row); //delete rows count

  //////update
  // var row = await db.update(
  //   table: 'user',
  //   updateData: {
  //     'nickname': 'test-${rng.nextInt(100)}',
  //   },
  //   where: {
  //     'id': 2,
  //   },
  //   debug: true,
  // );
  // print(row); //update affectedRows
  //////insertAll
  // var row11 = await db.insertAll(table: 'user', insertData: [
  //   {
  //     'nickname': 'test-${rng.nextInt(100)}',
  //     'telphone': '+113888888888',
  //     'createTime': 1620577162252,
  //     'updateTime': 1620577162252,
  //   },
  //   {
  //     'nickname': 'test-${rng.nextInt(100)}',
  //     'telphone': '+113888888888',
  //     'createTime': 1620577162252,
  //     'updateTime': 1620577162252,
  //   }
  // ]);
  // print(row11);
  ////// base sql
  ///
  // var row12 = await db.query('SELECT * FROM su_user', []);
  // for (var item in row12.rows) {
  //   print(item.assoc());
  // }

  // var isAlive = await db.isConnectionAlive();
  // if (isAlive) {
  //   print('mysql is isAlive');
  // }
  // var row13 =
  //     await db.query('SELECT * FROM su_user WHERE id=2', [], debug: true);
  // print(row13.rows.first.assoc());
  // for (var item in row13.rows) {
  //   print(item.assoc());
  // }
  // for (final row in row13.rows) {
  //   print(row.colAt(0));
  //   print(row.colByName("nickname"));
  //   print(row.assoc());
  // }
  // db.close();
}
