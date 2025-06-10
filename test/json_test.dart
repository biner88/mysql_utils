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
        user: 'root',
        password: 'root',
        db: 'test_db',
        secure: true,
        // prefix: '',
        // maxConnections: 1000,
        // timeoutMs: 10000,
        // sqlEscape: true,
        pool: false,
        //collation: 'utf8mb4_general_ci',
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
    await db.query("DROP TABLE IF EXISTS `test_data4`");
    await db.query('''
      CREATE TABLE test_data4 (
        id INT AUTO_INCREMENT PRIMARY KEY,
        blob_col BLOB,
        text_col TEXT,
        json_col JSON
      );
    ''');
  });

  test('Execute: insert data ', () async {
    await db.insert(table: 'test_data4', insertData: {
      'json_col': {'json': 'json_value'},
      'text_col':
          'You can\'t have a better tomorrow if you are thinking about yesterday all the time.',
      'blob_col': Uint8List.fromList([1, 2, 3, 4, 5]),
    });
  });
  test('Execute: getOne json', () async {
    var req1 = await db.getOne(
      table: 'test_data4',
      fields: '*',
    );
    print(req1['json_col']);
    expect(req1['json_col']['json'], equals('json_value'));
  });
  test('Execute: getOne blob', () async {
    var req1 = await db.getOne(
      table: 'test_data4',
      fields: '*',
      excludeFields: 'json_col',
    );
    print(req1['blob_col']);
    expect(req1['blob_col'], equals([1, 2, 3, 4, 5]));
  });
  test('Execute: getOne text', () async {
    var req1 = await db.getOne(
      table: 'test_data4',
      fields: '*',
      excludeFields: 'text_col',
    );
    print(req1['text_col']);
    expect(
        req1['text_col'],
        equals(
            'You can\'t have a better tomorrow if you are thinking about yesterday all the time.'));
  });
  test('Execute: drop table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data4`");
  });
}
