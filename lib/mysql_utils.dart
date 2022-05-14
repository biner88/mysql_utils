import 'dart:async';

import 'package:mysql_client/mysql_client.dart';
import 'blob.dart';

///mysql helper
class MysqlUtils {
  ///database table prefix
  static late String _prefix;
  static late bool _pool = false;

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
    linkNum = 0,
    String prefix = '',
    bool pool = false,
    Function? errorLog,
    Function? sqlLog,
    Function? connectInit,
  }) {
    _prefix = prefix;
    _pool = pool;
    return MysqlUtils._internal(
        settings, linkNum, sqlLog, errorLog, connectInit);
  }

  MysqlUtils._internal([
    Map? settings,
    int linkNum = 0,
    this.sqlLog,
    this.errorLog,
    this.connectInit,
  ]) {
    if (settings != null) {
      _settings = settings;
    } else {
      throw ('settings is null');
    }
    if (_pool) {
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
      await query('select 1', []).timeout(Duration(milliseconds: 500),
          onTimeout: () {
        throw TimeoutException('test isConnectionAlive timeout.');
      });
      return true;
    } catch (e) {
      poolConn = createConnectionPool(_settings);
      // if ((await conn).activeConnectionsQty.) {

      // }
    }
    return true;
  }

  /// ```
  ///await db.startTrans();
  ///await db.rollback();
  /// ```
  Future<void> startTrans() async {
    if (transTimes == 0) {
      try {
        await query('start transaction', []);
        transTimes++;
      } catch (e) {
        _errorLog('MySQL: Transaction is not supported,' + e.toString());
        close();
        rethrow;
      }
    }
  }

  /// ```
  ///db.commit();
  /// ```
  Future<void> commit() async {
    if (transTimes > 0) {
      try {
        await query('commit', []);
        transTimes = 0;
      } catch (e) {
        _errorLog('MySQL: Please startTrans(),' + e.toString());
        close();
        rethrow;
      }
    }
  }

  /// ```
  ///db.rollback();
  /// ```
  Future<void> rollback() async {
    if (transTimes > 0) {
      try {
        await query('rollback', []);
        transTimes = 0;
      } catch (e) {
        _errorLog('MySQL: Please startTrans(),' + e.toString());
        close();
        rethrow;
      }
    }
  }

  /// ```
  /// await db.delete(
  ///   table:'table',
  ///   where: {'id':1}
  /// );
  /// ```
  Future<int> delete(
      {required String table, required where, debug = false}) async {
    int res = 0;
    table = _tableParse(table);
    var whp = _whereParse(where);
    var _where = whp['where'];
    var _values = whp['values'];
    try {
      var results =
          await query('DELETE FROM $table $_where ', _values, debug: debug);
      res = results.affectedRows.toInt();
    } catch (e) {
      _errorLog(e.toString());
      close();
    }
    return res;
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
    required Map updateData,
    required where,
    debug = false,
  }) async {
    int res = 0;
    table = _tableParse(table);

    var whp = _whereParse(where);
    var _where = whp['where'];
    var _values = whp['values'];

    if (updateData.isEmpty) {
      throw ('updateData.length!=0');
    }
    var _updateValues = [];
    var _setkeys = '';
    updateData.forEach((key, value) {
      if (value is String || value is num) {
        if (_setkeys == '') {
          _setkeys = 'set ' + key + '= ?';
        } else {
          _setkeys += ' ,' + key + '= ?';
        }
        _updateValues.add(value);
      }
    });
    _values.forEach((element) {
      _updateValues.add(element);
    });
    try {
      var results = await query(
          'update $table $_setkeys $_where ', _updateValues,
          debug: debug);
      res = results.affectedRows.toInt();
    } catch (e) {
      _errorLog(e.toString());
      close();
    }
    return res;
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
  Future<List<int>> insertAll({
    required String table,
    required List<Map> insertData,
    replace = false,
    debug = false,
  }) async {
    List<int> lastInsertIDs = [];
    table = _tableParse(table);
    if (insertData.isEmpty) {
      throw ('insertData isEmpty');
    }
    if (insertData.isNotEmpty) {
      var _vals = <Object?>[];
      var _keys = '';
      var _wh = '';
      insertData.first.forEach((key, value) {
        if (value is String || value is num) {
          if (_keys == '') {
            _keys = '`' + key + '`';
            _wh = '?';
          } else {
            _keys += ', `' + key + '`';
            _wh += ', ?';
          }
        }
      });

      insertData.forEach((ele) {
        var sd = <Object?>[];
        ele.forEach((key1, value1) {
          sd.add(value1);
        });
        _vals.add(sd);
      });

      try {
        var results = await queryMulti(
            '${replace ? 'REPLACE' : 'INSERT'} INTO $table ($_keys) VALUES ($_wh)',
            _vals.cast(),
            debug: debug);
        return results;
      } catch (e) {
        _errorLog(e.toString());
        close();
      }
    }
    return lastInsertIDs;
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
    required Map insertData,
    replace = false,
    debug = false,
  }) async {
    table = _tableParse(table);
    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }
    if (insertData.isNotEmpty) {
      var _vals = [];
      var _keys = '';
      var _wh = '';
      insertData.forEach((key, value) {
        if (value is String || value is num) {
          if (_keys == '') {
            _keys = '`' + key + '`';
            _wh = '?';
          } else {
            _keys += ', `' + key + '`';
            _wh += ', ?';
          }
          _vals.add(value);
        }
      });
      try {
        var result = await query(
            '${replace ? 'REPLACE' : 'INSERT'} INTO $table ($_keys) VALUES ($_wh)',
            _vals,
            debug: debug);
        return result.lastInsertID.toInt();
      } catch (e) {
        _errorLog(e.toString());
        close();
      }
    }
    return 0;
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
    try {
      if (group != '') group = 'GROUP BY $group';
      if (having != '') having = 'HAVING $having';

      var whp = _whereParse(where);
      var _where = whp['where'];
      var _values = whp['values'];

      table = _tableParse(table);

      var results = await query(
          'SELECT count($fields) as _count FROM $table $_where $group $having',
          _values,
          debug: debug);
      return int.parse(_resultFormat(results).first['_count']);
    } catch (e) {
      _errorLog(e.toString());
      close();
      return 0;
    }
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
    try {
      if (group != '') group = 'GROUP BY $group';
      if (having != '') having = 'HAVING $having';

      if (fields == '') throw 'fields cant be empty';

      var whp = _whereParse(where);
      var _where = whp['where'];
      var _values = whp['values'];

      table = _tableParse(table);

      var results = await query(
          'SELECT AVG($fields) as _avg FROM $table $_where $group $having',
          _values,
          debug: debug);

      return double.parse(_resultFormat(results).first['_avg']);
    } catch (e) {
      _errorLog(e.toString());
      close();
      return 0;
    }
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
    try {
      if (group != '') group = 'GROUP BY $group';
      if (having != '') having = 'HAVING $having';
      if (fields == '') throw 'fields cant be empty';

      var whp = _whereParse(where);
      var _where = whp['where'];
      var _values = whp['values'];

      table = _tableParse(table);

      var results = await query(
          'SELECT max($fields) as _max FROM $table $_where $group $having',
          _values,
          debug: debug);
      return double.parse(_resultFormat(results).first['_max']);
    } catch (e) {
      _errorLog(e.toString());
      close();
      return 0;
    }
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
    try {
      if (group != '') group = 'GROUP BY $group';
      if (having != '') having = 'HAVING $having';
      if (fields == '') throw 'fields cant be empty';
      var whp = _whereParse(where);
      var _where = whp['where'];
      var _values = whp['values'];

      table = _tableParse(table);

      var results = await query(
          'SELECT MIN($fields) as _min FROM $table $_where $group $having',
          _values,
          debug: debug);
      return double.parse(_resultFormat(results).first['_min']);
    } catch (e) {
      _errorLog(e.toString());
      close();
      return 0;
    }
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

    var whp = _whereParse(where);
    var _where = whp['where'];
    var _values = whp['values'];

    table = _tableParse(table);
    limit = _limitParse(limit);
    var _sql =
        'SELECT $fields FROM $table $_where $group $having $order $limit';
    try {
      var results = await query(_sql, _values, debug: debug);
      var res = _resultFormat(results);
      return res;
    } catch (e) {
      _errorLog(e.toString());
      close();
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
    var res = await getAll(
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

  Future<void> close() async {
    if (!_pool) {
      (await singleConn).close();
    } else {
      (await poolConn).close();
    }
  }

  List<dynamic> _resultFormat(IResultSet results) {
    var _data = [];
    if (results.rows.isNotEmpty) {
      var d = [];
      for (var row in results.rows) {
        // if (row.assoc() is Blob) {
        //   d.add(row.assoc().toString());
        // } else {
        d.add(row.assoc());
        // }
      }
      _data = d;
    }
    return _data;
  }

  Map _whereParse(dynamic where) {
    var _where = '';
    var _values = [];
    if (where is String && where != '') {
      _where = 'WHERE $where';
    } else if (where is Map && where.isNotEmpty) {
      var _vals = [];
      var _keys = '';
      where.forEach((key, value) {
        if (value is String || value is num) {
          if (_keys == '') {
            _keys = key + '= ?';
          } else {
            _keys += ' AND ' + key + '= ?';
          }
          _vals.add(value);
        }
        if (value is List) {
          switch (value[0]) {
            case 'in':
              if (_keys == '') {
                _keys = key + ' IN(${value[1].join(',')})';
              } else {
                _keys += ' AND ' + key + ' IN(${value[1].join(',')})';
              }
              break;
            case 'notin':
              if (_keys == '') {
                _keys = key + ' NOT IN(${value[1].join(',')})';
              } else {
                _keys += ' AND ' + key + ' NOT IN(${value[1].join(',')})';
              }
              break;
            case 'between':
              if (_keys == '') {
                _keys = key + ' BETWEEN ? AND ?';
              } else {
                _keys += ' AND ' + key + ' BETWEEN ? AND ?';
              }
              _vals.add(value[1]);
              _vals.add(value[2]);
              break;
            case 'notbetween':
              if (_keys == '') {
                _keys = key + ' NOT BETWEEN ? AND ?';
              } else {
                _keys += ' AND ' + key + ' NOT BETWEEN ? AND ?';
              }
              _vals.add(value[1]);
              _vals.add(value[2]);
              break;
            default:
              if (_keys == '') {
                _keys = key + ' ' + value[0] + ' ?';
              } else {
                _keys += ' AND ' + key + ' ' + value[0] + ' ?';
              }
              _vals.add(value[1]);
          }
        }
      });
      _where = 'WHERE $_keys';
      _values = _vals;
    }
    return {
      'where': _where,
      'values': _values,
    };
  }

  ///query
  Future<IResultSet> query(String sql, List<dynamic> values,
      {debug = false}) async {
    var queryStr = '$sql  $values';
    queryTimes++;
    if (debug) _sqlLog(queryStr);
    bool transaction = false;
    if (sql == 'start transaction' || sql == 'commit' || sql == 'rollback') {
      transaction = true;
    }
    if (transaction) {
      if (_pool) {
        return await (await poolConn).execute(sql, {});
      } else {
        return await (await singleConn).execute(sql, {});
      }
    } else {
      PreparedStmt stmt;
      if (_pool) {
        stmt = await (await poolConn).prepare(sql);
      } else {
        stmt = await (await singleConn).prepare(sql);
      }
      var res = await stmt.execute(values);
      await stmt.deallocate();
      return res;
    }
  }

  ///queryMulti
  Future<List<int>> queryMulti(String sql, Iterable<List<Object?>> values,
      {debug = false}) async {
    var queryStr = '$sql  $values';
    queryTimes++;
    if (debug) _sqlLog(queryStr);
    PreparedStmt stmt;
    if (_pool) {
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
