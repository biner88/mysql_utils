import 'dart:typed_data';

import 'package:mysql_utils/mysql_utils.dart';
import 'package:test/test.dart';

void main() {
  late MysqlUtils db;
  setUpAll(() async {
    db = MysqlUtils(
      settings: MysqlUtilsSettings(
        host: '127.0.0.1',
        port: 3306,
        user: 'your_user',
        password: 'your_password',
        db: 'testdb',
        secure: true,
        prefix: '',
        maxConnections: 1000,
        timeoutMs: 10000,
        sqlEscape: true,
        pool: true,
        collation: 'utf8mb4_general_ci',
        // debug: true,
        // securityContext: SecurityContext(),
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
      },
    );
  });

  tearDownAll(() async {
    await db.close();
  });

  test('Execute: create table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data`");
    await db.query('''
      CREATE TABLE test_data (
        id INT AUTO_INCREMENT PRIMARY KEY,
        int_column INT,
        string_column VARCHAR(255),
        datetime_column DATETIME,
        blob_column BLOB,
        bool_column TINYINT(1),
        decimal_column DECIMAL(10,2),
        float_column FLOAT,
        double_column DOUBLE,
        date_column DATE,
        time_column TIME,
        year_column YEAR,
        json_column JSON
      )
    ''');
  });

  test('Execute: insert data ', () async {
    Map<String, dynamic> data = {
      'int_column': 1001,
      'string_column': 'text\'s',
      'datetime_column': '2025-01-01 12:00:00',
      'blob_column': Uint8List.fromList([0x48, 0x65, 0x6c, 0x6c, 0x6f]),
      'bool_column': true,
      'decimal_column': 1222.34,
      'float_column': 10.12,
      'double_column': 0.123456,
      'date_column': DateTime.now(),
      'time_column': '15:30:45',
      'year_column': DateTime.now().year,
      'json_column': '{"name": "mysql_utils"}'
    };
    var req1 = await db.insert(table: 'test_data', insertData: data);
    expect(req1, BigInt.one);
    var req2 = await db.insertAll(table: 'test_data', insertData: [data, data]);
    expect(req2, BigInt.two);
  });

  test('Execute: getOne ', () async {
    var req1 = await db.getOne(
      table: 'test_data',
      fields: 'id',
      where: {'id': 2},
    );
    expect(req1['id'], 2);
  });

  test('Execute: getAll ', () async {
    var req1 = await db.getAll(
      table: 'test_data',
      fields: 'id',
      where: {'int_column': 1001},
    );
    expect(req1.length, 3);
  });

  test('Execute: update ', () async {
    var req1 = await db.update(
      table: 'test_data',
      updateData: {'int_column': 1002},
      where: {'id': 2},
    );
    expect(req1, BigInt.from(1));
    var req2 = await db.update(
      table: 'test_data',
      updateData: {'int_column': 1003},
      where: {'id': 3},
    );
    expect(req2, BigInt.from(1));
  });

  test('Execute: count ', () async {
    var req1 = await db.count(
      table: 'test_data',
      fields: 'int_column',
      where: {
        'id': ['>', 0]
      },
    );
    expect(req1, 3);
  });

  test('Execute: avg ', () async {
    var req1 = await db.avg(
      table: 'test_data',
      fields: 'int_column',
      where: {
        'id': ['>', 0]
      },
    );
    expect(req1, 1002.0);
  });

  test('Execute: min ', () async {
    var req1 = await db.min(
      table: 'test_data',
      fields: 'int_column',
      where: {
        'id': ['>', 0]
      },
    );
    expect(req1, 1001);
  });

  test('Execute: max ', () async {
    var req1 = await db.max(
      table: 'test_data',
      fields: 'int_column',
      where: {
        'id': ['>', 0]
      },
    );
    expect(req1, 1003);
  });

  test('Execute: transaction', () async {
    await db.startTrans();
    var req1 = await db.delete(
      table: 'test_data',
      where: {
        'id': ['>', 0]
      },
    );
    expect(req1, BigInt.from(3));
    await db.rollback();
  });

  test('Execute: delete ', () async {
    var req1 = await db.delete(
      table: 'test_data',
      where: {
        'id': ['>', 0]
      },
    );
    expect(req1, BigInt.from(3));
  });

  test('Execute: drop table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data`");
  });
}
