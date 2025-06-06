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
        // prefix: '',
        // maxConnections: 1000,
        // timeoutMs: 10000,
        // sqlEscape: true,
        pool: true,
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
    await db.query("DROP TABLE IF EXISTS `test_data`");
    await db.query('''
      CREATE TABLE test_data (
        id INT AUTO_INCREMENT PRIMARY KEY,
        string_column VARCHAR(255)
      )
    ''');
  });

  test('Execute: insert data ', () async {
    Map<String, dynamic> data = {
      'string_column': '一大串中文',
    };
    var req1 = await db.insert(table: 'test_data', insertData: data);
    expect(req1, BigInt.one);
  });

  test('Execute: getOne ', () async {
    var req1 = await db.getOne(table: 'test_data', where: {'string_column': "一大\\'串中文"});
    // var req1 = await db.getOne(table: 'test_data', where: {'id': 1});
    print(req1);
    // expect(req1['id'], 1);
  });

  // test('Execute: transaction', () async {
  //   await db.startTrans();
  //   var req1 = await db.delete(
  //     table: 'test_data',
  //     where: {
  //       'id': ['>', 0]
  //     },
  //   );
  //   expect(req1, BigInt.from(3));
  //   await db.rollback();
  // });

  // test('Execute: delete ', () async {
  //   var req1 = await db.delete(
  //     table: 'test_data',
  //     where: {
  //       'id': ['>', 0]
  //     },
  //   );
  //   expect(req1, BigInt.from(3));
  //   await db.query("DROP TABLE IF EXISTS `test_data`");
  // });

  // test('Execute: drop table ', () async {
  //   await db.query("DROP TABLE IF EXISTS `test_data`");
  // });
}
