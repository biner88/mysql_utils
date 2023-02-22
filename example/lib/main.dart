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
      'prefix': 'su_',
      'pool': false,
      'collation': 'utf8mb4_general_ci',
    },
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
  ////insert
  var res3 = await db.insert(
    table: 'user',
    insertData: {
      'nickname': '中文测试-${rng.nextInt(100)}',
      'telphone': '+113888888888',
      'createTime': 1620577162252,
      'updateTime': 1620577162252,
    },
  );
  await db.close();
  print(res3); //lastInsertID
  //////getOne
  // var row1 = await db.getOne(
  //   table: 'user',
  //   fields: '*',
  //   where: {
  //     // 'id': 2,
  //     // 'id2': ['notbetween', 1, 4],
  //     // 'id': ['between', 1, 4],
  //     'createTime': ['>', 1],
  //     // 'nickname': ['like', '%biner%'],
  //   },
  //   debug: true,
  // );
  // await db.close();
  // print(row1); //Map
  //////getAll
  // var row2 = await db.getAll(
  //   table: 'user',
  //   fields: '*',
  //   where: {
  //     // 'nickname': 'biner2',
  //     // 'id': ['between', '1,4'],
  //     //'id': ['notbetween', '1,4'],
  //     // 'email2': ['=', 'sss@google.com'],
  //     // 'news_title': ['like', '%name%'],
  //     'id': ['>', 1],
  //     // 'id': ['in', [1,2,3]]
  //   },
  //   debug: true,
  // );
  // await db.close();
  // print(row2); //List<Map>
  //getAll, Multi table
  // var res4 = await db.getAll(
  //   table: 'user tb1,name tb2',
  //   fields: 'tb2.name',
  //   where: 'tb2.id>0 and tb2.id=tb1.id',
  //   debug: true,
  // );
  // print(res4); //[{name: hh}, {name: joy}]
  // await db.close();
  //////count'
  // var row5 = await db.count(
  //   table: 'user',
  //   fields: '*',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row5);
  // await db.close();
  //////avg
  // var row6 = await db.avg(
  //   table: 'user',
  //   fields: 'id',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row6);
  // await db.close();
  ////min
  // var row7 = await db.min(
  //   table: 'user',
  //   fields: 'id',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row7);
  // await db.close();
  //////max
  // var row8 = await db.max(
  //   table: 'user',
  //   fields: 'id',
  //   where: {
  //     'id': ['>', 0]
  //   },
  //   debug: true,
  // );
  // print(row8);
  // await db.close();
  //////delete
  // var row9 = await db.delete(
  //   table: 'user',
  //   where: {
  //     // 'id': ['=', 2],
  //     'id': 3
  //   },
  //   debug: true,
  // );
  // print(row9); //delete rows count
  // await db.close();
  //////update
  // var row10 = await db.update(
  //   table: 'user',
  //   updateData: {
  //     'nickname': '想vvb-${rng.nextInt(100)}',
  //   },
  //   where: {
  //     'id': 4,
  //   },
  //   debug: true,
  // );
  // print(row10); //update affectedRows
  // await db.close();
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
  // await db.close();
  ////// base sql
  ///
  // var row12 = await db.query('SELECT * FROM su_user');
  // for (var item in row12.rows) {
  //   print(item);
  // }
  // await db.close();
  // //Alive check
  // var isAlive = await db.isConnectionAlive();
  // if (isAlive) {
  //   print('mysql is isAlive');
  // }
  // await db.close();
  // isAlive = await db.isConnectionAlive();
  // if (!isAlive) {
  //   print('mysql is isDead');
  // }

  ///base
  //// var row13 = await db.query('SELECT * FROM su_user WHERE id=2', debug: true);
  // var row13 = await db.query('SELECT * FROM su_user WHERE id=:id',
  //     values: {
  //       'id': 1,
  //     },
  //     debug: true);

  // print(row13.toMap());
  //// print(row13.rowsAssoc.first.assoc());
  // for (var item in row13.rowsAssoc) {
  //   print(item.assoc());
  // }
  // for (final row in row13.rowsAssoc) {
  //   print(row.colAt(0));
  //   print(row.colByName("nickname"));
  //   print(row.assoc());
  // }
  // db.close();

  ///Transactions
  // await db.startTrans();
  // await db.delete(table: 'user', where: {'id': 25}, debug: true);
  // await db.delete(table: 'user1', where: {'id': 26}, debug: true);
  // await db.commit();
  // await db.close();

  await db.insert(
    table: 'text',
    insertData: {
      'name': 'test',
      'content': 'String _where = _whereParse(where, extraWhere: extraWhere);',
    },
  );

  var result = await db.getAll(table: 'text', where: {'name': 'test'}, extraWhere: "Match(content) Against('String')");
  print(result);
  await db.close();

}
