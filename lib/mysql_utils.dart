import 'dart:async';
import 'dart:typed_data';
import 'package:mysql_client/mysql_client.dart';
import 'package:mysql_client/mysql_protocol.dart';

///mysql helper
class MysqlUtils {
  late Future<MySQLConnectionPool> poolConn;
  late Future<MySQLConnection> singleConn;
  late Map _settings = {};

  int queryTimes = 0;
  int transTimes = 0;

  ///sql error log
  final Function? errorLog;

  /// show sql log
  final Function? sqlLog;

  ///
  final Function? connectInit;
  factory MysqlUtils({
    required Map settings,
    Function? errorLog,
    Function? sqlLog,
    Function? connectInit,
  }) {
    return MysqlUtils._internal(settings, sqlLog, errorLog, connectInit);
  }

  MysqlUtils._internal([
    Map? settings,
    this.sqlLog,
    this.errorLog,
    this.connectInit,
  ]) {
    if (settings != null) {
      _settings = settings;
    } else {
      throw ('settings is null');
    }
    if (_settings['pool']) {
      poolConn = createConnectionPool(settings);
    } else {
      singleConn = createConnectionSingle(settings);
    }
  }

  ///create single connection
  Future<MySQLConnection> createConnectionSingle(Map settings) async {
    final conn = await MySQLConnection.createConnection(
      host: settings['host'] ?? '127.0.0.1',
      port: settings['port'] ?? 3306,
      userName: settings['user'] ?? '',
      password: settings['password'] ?? '',
      databaseName: settings['db'] ?? '', // optional,
      secure: settings['secure'] ?? false,
      collation: settings['collation'] ?? 'utf8mb4_general_ci',
    );
    await conn.connect();
    return conn;
  }

  ///create pool connection
  Future<MySQLConnectionPool> createConnectionPool(Map settings) async {
    return MySQLConnectionPool(
      host: settings['host'] ?? '127.0.0.1',
      port: settings['port'] ?? 3306,
      userName: settings['user'] ?? '',
      password: settings['password'] ?? '',
      maxConnections: settings['maxConnections'] ?? 10,
      databaseName: settings['db'] ?? '', // optional,
      secure: settings['secure'] ?? false,
      collation: settings['collation'] ?? 'utf8mb4_general_ci',
    );
  }

  ///isConnectionAlive
  Future<bool> isConnectionAlive() async {
    try {
      await query('select 1').timeout(Duration(milliseconds: 500),
          onTimeout: () {
        throw TimeoutException('test isConnectionAlive timeout.');
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ```
  ///await db.startTrans();
  /// ```
  Future<void> startTrans() async {
    if (transTimes == 0) {
      await query('start transaction');
    } else {
      throw ('Only supports startTrans once');
    }
  }

  /// ```
  ///db.commit();
  /// ```
  Future<void> commit() async {
    if (transTimes > 0) {
      await query('commit');
      transTimes = 0;
    }
  }

  /// ```
  ///db.rollback();
  /// ```
  Future<void> rollback() async {
    if (transTimes > 0) {
      await query('rollback');
      transTimes = 0;
    }
  }

  /// ```
  /// await db.delete(
  ///   table:'table',
  ///   where: {'id':1}
  /// );
  /// ```
  Future<int> delete({
    required String table,
    required where,
    debug = false,
  }) async {
    table = _tableParse(table);
    String _where = _whereParse(where);
    var results = await query('DELETE FROM $table $_where ', debug: debug);
    return results.affectedRows.toInt();
  }

  ///```
  /// await db.update(
  ///   table: 'table',
  ///   updateData:{
  ///     'telphone': '1231',
  ///     'create_time': 12,
  ///     'update_time': 12121212,
  ///     'email': 'biner@dd.com'
  ///   },
  ///   where:{
  ///   'id':1,
  /// });
  ///```
  Future<int> update({
    required String table,
    required Map<String, dynamic> updateData,
    required where,
    debug = false,
  }) async {
    table = _tableParse(table);
    String _where = _whereParse(where);

    if (updateData.isEmpty) {
      throw ('updateData.length!=0');
    }

    List<String> _setkeys = [];
    updateData.forEach((key, value) {
      _setkeys.add('`$key` = :$key ');
    });

    String _setValue = _setkeys.join(',');
    String _sql = 'update $table SET $_setValue $_where';
    IResultSet results = await query(
      _sql,
      values: updateData,
      debug: debug,
    );
    return results.affectedRows.toInt();
  }

  ///```
  /// await db.insertAll(
  ///   table: 'table',
  ///   insertData: [
  ///       {
  ///         'telphone': '13888888888',
  ///         'create_time': 1111111,
  ///         'update_time': 12121212,
  ///         'email': 'biner@dd.com'
  ///       },
  ///       {
  ///         'telphone': '13881231238',
  ///         'create_time': 324234,
  ///         'update_time': 898981,
  ///         'email': 'xxx@dd.com'
  ///       }
  /// ]);
  ///```
  Future<int> insertAll({
    required String table,
    required List<Map<String, dynamic>> insertData,
    replace = false,
    debug = true,
  }) async {
    // List<int> lastInsertIDs = [];

    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }
    table = _tableParse(table);
    List<String> _fields = [];
    List<String> _values = [];
    insertData.first.forEach((key, value) => _fields.add('`$key`'));
    insertData.forEach((val) {
      List _t = [];
      val.forEach((key, value) {
        if (value is num) {
          _t.add(value);
        } else {
          _t.add('\'$value\'');
        }
      });
      _values.add('(${_t.join(',')})');
    });
    String _fieldsString = _fields.join(',');
    String _valuesString = _values.join(',');
    String _sql =
        '${replace ? 'REPLACE' : 'INSERT'} INTO $table ($_fieldsString) VALUES $_valuesString';
    IResultSet result = await query(_sql, debug: debug);
    return result.affectedRows.toInt();
  }

  ///```
  /// await db.insert(
  ///   table: 'table',
  ///   insertData: {
  ///     'telphone': '+113888888888',
  ///     'create_time': 1620577162252,
  ///     'update_time': 1620577162252,
  ///   },
  /// );
  ///```
  Future<int> insert({
    required String table,
    required Map<String, dynamic> insertData,
    replace = false,
    debug = false,
  }) async {
    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }
    table = _tableParse(table);
    List<String> _fields = [];
    List<String> _values = [];
    insertData.forEach((key, value) {
      _fields.add('`$key`');
      _values.add(':$key');
    });
    String _fieldsString = _fields.join(',');
    String _valuesString = _values.join(',');
    String _sql =
        '${replace ? 'REPLACE' : 'INSERT'} INTO $table ($_fieldsString) VALUES ($_valuesString)';
    IResultSet result = await query(_sql, values: insertData, debug: debug);
    return result.lastInsertID.toInt();
  }

  ///```
  /// await db.count(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<int> count({
    required String table,
    fields = '*',
    where = const {},
    group = '',
    having = '',
    debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';

    String _where = _whereParse(where);
    table = _tableParse(table);

    IResultSet results = await query(
        'SELECT count($fields) as _count FROM $table $_where $group $having',
        debug: debug);
    return int.parse(results.rows.first.colByName('_count') ?? '0');
  }

  ///```
  /// await db.avg(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<double> avg({
    required String table,
    fields = '',
    where = const {},
    group = '',
    having = '',
    debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (fields == '') throw 'fields cant be empty';

    String _where = _whereParse(where);
    table = _tableParse(table);

    IResultSet results = await query(
        'SELECT AVG($fields) as _avg FROM $table $_where $group $having',
        debug: debug);
    return double.parse(results.rows.first.colByName('_avg') ?? '0');
  }

  ///```
  /// await db.max(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<double> max({
    required String table,
    fields = '',
    where = const {},
    group = '',
    having = '',
    debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (fields == '') throw 'fields cant be empty';

    String _where = _whereParse(where);
    table = _tableParse(table);

    IResultSet results = await query(
        'SELECT max($fields) as _max FROM $table $_where $group $having',
        debug: debug);
    return double.parse(results.rows.first.colByName('_max') ?? '0');
  }

  ///```
  /// await db.min(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<double> min({
    required String table,
    fields = '',
    where = const {},
    group = '',
    having = '',
    debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (fields == '') throw 'fields cant be empty';
    String _where = _whereParse(where);
    table = _tableParse(table);

    IResultSet results = await query(
        'SELECT MIN($fields) as _min FROM $table $_where $group $having',
        debug: debug);
    return double.parse(results.rows.first.colByName('_min') ?? '0');
  }

  ///```
  /// await db.getAll(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   order: 'id desc',
  ///   limit: 10,//10 or '10 ,100'
  ///   debug: false,
  ///   where: {'email': 'xxx@google.com','id': ['between', '1,4'],'email': ['=', 'sss@google.com'],'news_title': ['like', '%name%'],'user_id': ['>', 1]},
  /// );
  ///```
  Future<List<dynamic>> getAll({
    required String table,
    fields = '*',
    where = const {},
    group = '',
    having = '',
    order = '',
    limit = '',
    debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (order != '') order = 'ORDER BY $order';

    String _where = _whereParse(where);
    table = _tableParse(table);
    limit = _limitParse(limit);

    String _sql =
        'SELECT $fields FROM $table $_where $group $having $order $limit';

    IResultSet results = await query(_sql, debug: debug);
    if (results.numOfRows > 0) {
      return _resultFormat(results);
    } else {
      return [];
    }
  }

  ///```
  /// await db.getOne(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   order: 'id desc',
  ///   debug: false,
  ///   where: {'email': 'xxx@google.com'},
  /// );
  ///```
  Future<Map> getOne({
    required String table,
    fields = '*',
    where = const {},
    group = '',
    having = '',
    order = '',
    debug = false,
  }) async {
    List<dynamic> res = await getAll(
      table: table,
      fields: fields,
      where: where,
      group: group,
      having: having,
      order: order,
      limit: 1,
      debug: debug,
    );

    if (res.isNotEmpty) {
      return res.first;
    } else {
      return {};
    }
  }

  String _tableParse(String table) {
    var _table = '';
    String _prefix = _settings['prefix'];
    if (table.contains(',')) {
      var tbs = [];
      for (var tb in table.split(',')) {
        var vl = tb.split(' ');
        if (_prefix == '') {
          tbs.add('`' + vl.first + '` ' + vl.last);
        } else {
          tbs.add('`' + _prefix + vl.first + '` ' + vl.last);
        }
      }
      _table = tbs.join(',');
    } else {
      if (_prefix == '') {
        _table = '`' + table.trim() + '`';
      } else {
        _table = '`' + _prefix + table.trim() + '`';
      }
    }
    return _table;
  }

  ///..limit(10) or ..limit('10 ,100')
  String _limitParse(dynamic limit) {
    if (limit is int) {
      return 'LIMIT $limit';
    }
    if (limit is String && limit != '') {
      return 'LIMIT $limit';
    }
    return '';
  }

  List<dynamic> _resultFormat(IResultSet results) {
    var _data = [];
    if (results.rows.isNotEmpty) {
      // results.rows.map((e) => _data.add(e.typedAssoc()));
      var d = [];
      for (ResultSetRow row in results.rows) {
        d.add(row.typedAssoc());
      }
      _data = d;
    }
    return _data;
  }

  String _whereParse(dynamic where) {
    String _where = '';
    List<String> _fields = [];
    if (where is String && where != '') {
      _where = 'WHERE $where';
    } else if (where is Map && where.isNotEmpty) {
      var _keys = '';
      where.forEach((key, value) {
        _fields.add(key);
        if (value is String || value is num) {
          if (value is String) {
            if (_keys == '') {
              _keys = '$key = \'$value\'';
            } else {
              _keys += ' AND $key = \'$value\'';
            }
          } else if (value is num) {
            if (_keys == '') {
              _keys = '($key = $value)';
            } else {
              _keys += ' AND ($key = $value)';
            }
          }

          // _vals.add(value);
        }
        if (value is List) {
          switch (value[0]) {
            case 'in':
            case 'notin':
            case 'between':
            case 'notbetween':
            case 'like':
            case 'notlike':
              Map _ex = {
                'in': 'IN',
                'notin': 'NOT IN',
                'between': 'BETWEEN',
                'notbetween': 'NOT BETWEEN',
                'like': 'LIKE',
                'notlike': 'NOT LIKE',
              };
              String _wh = '';
              if (value[0] == 'in' || value[0] == 'notin') {
                _wh = '$key ${_ex[value[0]]}(${value[1].join(',')})';
              }
              if (value[0] == 'between' || value[0] == 'notbetween') {
                _wh = '($key ${_ex[value[0]]} ${value[1]} AND ${value[2]})';
              }
              if (value[0] == 'like' || value[0] == 'notlike') {
                _wh = '($key ${_ex[value[0]]} \'${value[1]}\')';
              }
              if (_keys == '') {
                _keys = _wh;
              } else {
                _keys += ' AND $_wh';
              }
              break;
            default:
              //>,=,<,<>
              String _wh = '($key ${value[0]} ${value[1]})';
              if (_keys == '') {
                _keys = _wh;
              } else {
                _keys += ' AND $_wh';
              }
          }
        }
      });
      _where = 'WHERE $_keys';
    }
    return _where;
  }

  ///errorRack
  Future<void> errorRollback() async {
    if (transTimes > 0) {
      rollback();
    }
  }

  ///close
  Future<void> close() async {
    if (!_settings['pool']) {
      (await singleConn).close();
    } else {
      (await poolConn).close();
    }
  }

  Future<IResultSet> query(
    String sql, {
    Map<String, dynamic> values = const {},
    debug = false,
  }) async {
    var queryStr = '$sql  $values';
    queryTimes++;
    if (debug) _sqlLog(queryStr);
    bool transaction = false;
    if (sql == 'start transaction' || sql == 'commit' || sql == 'rollback') {
      transaction = true;
    }

    try {
      if (transaction) {
        if (_settings['pool']) {
          return await (await poolConn).execute(sql, {});
        } else {
          return await (await singleConn).execute(sql, {});
        }
      } else {
        IResultSet res;
        if (_settings['pool']) {
          res = await (await poolConn).execute(sql, values);
        } else {
          res = await (await singleConn).execute(sql, values);
        }
        return res;
      }
    } catch (e) {
      _errorLog(e.toString());
      errorRollback();
      final okPacket = MySQLPacket.decodeGenericPacket(Uint8List.fromList([]));
      final EmptyResultSet empty =
          EmptyResultSet(okPacket: okPacket.payload as MySQLPacketOK);
      return empty;
    }
  }

  ///queryMulti
  Future<List<int>> queryMulti(String sql, Iterable<List<Object?>> values,
      {debug = false}) async {
    var queryStr = '$sql  $values';
    queryTimes++;
    if (debug) _sqlLog(queryStr);
    PreparedStmt stmt;
    if (_settings['pool']) {
      stmt = await (await poolConn).prepare(sql);
    } else {
      stmt = await (await singleConn).prepare(sql);
    }
    List<int> res = [];
    values.forEach(
      (val) async {
        res.add((await stmt.execute(val)).lastInsertID.toInt());
      },
    );
    await stmt.deallocate();
    return res;
  }

  void _errorLog(String e) {
    if (errorLog != null) {
      errorLog!(e);
    } else {
      throw e;
    }
  }

  void _sqlLog(String sql) {
    if (sqlLog != null) {
      sqlLog!(sql);
    }
  }
}
