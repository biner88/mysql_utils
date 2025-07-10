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
      ),
    );
  });

  tearDownAll(() async {
    await db.close();
  });

  test('Execute: create table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data6`");
    await db.query('''
      CREATE TABLE test_data6 (
        id INT AUTO_INCREMENT PRIMARY KEY,
        increase_col int NOT NULL,
        decrease_col int NOT NULL
      );
    ''');
    await db.insert(
      table: 'test_data6',
      insertData: {
        'increase_col': 1,
        'decrease_col': 1,
      },
    );
  });

  test('Execute: decrease and increase data ', () async {
    final res = await db.update(
      table: 'test_data6',
      updateData: {
        'increase_col': ['+', 1],
        'decrease_col': ['-', 1]
      },
      where: {'id': 1},
    );
    expect(res, BigInt.one);
    final res2 = await db.getOne(table: 'test_data6', where: {'id': 1});
    expect(res2['increase_col'], 2);
    expect(res2['decrease_col'], 0);
  });

  test('Execute: drop table ', () async {
    await db.query("DROP TABLE IF EXISTS `test_data6`");
  });
}
