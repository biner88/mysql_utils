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
    await db.query("DROP TABLE IF EXISTS `test_data3`");
    await db.query('''
      CREATE TABLE test_data3 (
        id BINARY(16) PRIMARY KEY NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
        name VARCHAR(255)
      );
    ''');
  });

  test('Execute: insert data ', () async {
    await db.query('INSERT INTO test_data3 (name) VALUES ("binary data test")');
    final result = await db.query("SELECT (id) FROM test_data3");
    final row = result.rows.first;
    final uuid = binaryToUuid(row['id']);

    final result2 =
        await db.query("SELECT BIN_TO_UUID(id) as UUID FROM test_data3");
    final row2 = result2.rows.first;

    expect(uuid, row2['UUID']);
  });

  test('Execute: drop table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data3`");
  });
}

String binaryToUuid(String idStr) {
  final bytes = Uint8List.fromList(idStr.codeUnits);
  assert(bytes.length == 16);
  String hex = _bytesToHex(bytes);
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

String _bytesToHex(List<int> bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
