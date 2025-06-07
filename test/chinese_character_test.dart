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
    await db.query("DROP TABLE IF EXISTS `test_data2`");
    await db.query('''
      CREATE TABLE test_data2 (
        id INT AUTO_INCREMENT PRIMARY KEY,
        string_column VARCHAR(255)
      )
    ''');
  });

  test('Execute: insert data ', () async {
    Map<String, dynamic> data = {
      'string_column': '一大\'串中文',
    };
    var req1 = await db.insert(table: 'test_data2', insertData: data);
    expect(req1, BigInt.one);
    Map<String, dynamic> data2 = {
      'string_column': 'mysql 测试',
    };
    var req2 = await db.insert(table: 'test_data2', insertData: data2);
    expect(req2, BigInt.two);
  });

  test('Execute: getOne Where', () async {
    var reqEq = await db.getOne(table: 'test_data2', where: {'string_column': "一大\'串中文", 'id': 1});
    expect(reqEq['id'], 1);
    //
    var reqIn = await db.getOne(table: 'test_data2', where: {
      'id': [
        'in',
        [1, 2]
      ]
    });
    expect(reqIn['id'], 1);
    var reqNotIn = await db.getOne(table: 'test_data2', where: {
      'id': [
        'notin',
        [0, 3]
      ]
    });
    expect(reqNotIn['id'], 1);
    var reqBetween = await db.getOne(table: 'test_data2', where: {
      'id': ['between', 1, 4]
      // 'id': ['between', '1,4'] // Deprecated
    });
    expect(reqBetween['id'], 1);
    var reqNotBetween = await db.getOne(table: 'test_data2', where: {
      'id': ['notbetween', 3, 4]
      // 'id': ['notbetween', '1,4'] // Deprecated
    });
    expect(reqNotBetween['id'], 1);
    var reqLike = await db.getOne(table: 'test_data2', where: {
      'string_column': ['like', '%串%']
    });
    expect(reqLike['id'], 1);
    var reqNotLike = await db.getOne(table: 'test_data2', where: {
      'string_column': ['notlike', '%mysql%']
    });
    expect(reqNotLike['id'], 1);
    var reqEq0 = await db.getOne(table: 'test_data2', where: {
      'string_column': ['=', '一大\'串中文']
    });
    expect(reqEq0['id'], 1);
    //
    var reqEq1 = await db.getOne(table: 'test_data2', where: {'string_column': '一大\'串中文'});
    expect(reqEq1['id'], 1);
    //
    var reqEq2 = await db.getOne(table: 'test_data2', where: {'string_column': '一大\'串中文'});
    expect(reqEq2['string_column'], '一大\'串中文');
    //
    var reqGt = await db.getOne(table: 'test_data2', where: {
      'id': ['>', 0]
    });
    expect(reqGt['id'], 1);
    //
    var reqLt = await db.getOne(table: 'test_data2', where: {
      'id': ['<', 2]
    });
    expect(reqLt['id'], 1);
    //
    var reqNotEq1 = await db.getOne(table: 'test_data2', where: {
      'id': ['<>', 2]
    });
    expect(reqNotEq1['id'], 1);
    //
    var reqNotEq2 = await db.getOne(table: 'test_data2', where: {
      'id': ['!=', 2]
    });
    expect(reqNotEq2['id'], 1);
    // sql
    var reqSql = await db.getOne(table: 'test_data2', where: {'_SQL': 'id<2'});
    expect(reqSql['id'], 1);
    //
    var reqSq2 = await db.query('select * from test_data2 where id<2');
    expect(reqSq2.rows.first['id'], 1);
  });

  test('Execute: drop table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data2`");
  });
}
