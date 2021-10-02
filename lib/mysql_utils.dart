import 'dart:async';
import 'package:mysql1/mysql1.dart';
// import 'package:mysql1/src/single_connection.dart';
export 'package:mysql1/mysql1.dart';

///mysql helper
class MysqlUtils {
  ///database table prefix
  static late String _prefix;
  static final Map<int, MysqlUtils> _sync = {};
  late Future<MySqlConnection> conn;
  int queryTimes = 0;
  int transTimes = 0;
  ConnectionSettings _settings = ConnectionSettings();

  ///sql error log
  final Function? errorLog;

  /// show sql log
  final Function? sqlLog;

  ///
  final Function? connectInit;
  factory MysqlUtils({
    ConnectionSettings? settings,
    linkNum = 0,
    String prefix = '',
    bool pool = false,
    Function? errorLog,
    Function? sqlLog,
    Function? connectInit,
  }) {
    _prefix = prefix;

    if (_sync[linkNum] != null && pool) {
      return _sync[linkNum]!;
    } else {
      final instance = MysqlUtils._internal(
          settings, linkNum, sqlLog, errorLog, connectInit);
      if (pool) _sync[linkNum] = instance;
      return instance;
    }
  }

  MysqlUtils._internal([
    ConnectionSettings? settings,
    int linkNum = 0,
    this.sqlLog,
    this.errorLog,
    this.connectInit,
  ]) {
    if (settings != null) {
      _settings = settings;
    }
    conn = createConnection();
  }

  ///create connection
  Future<MySqlConnection> createConnection() async {
    return Future<MySqlConnection>(() async {
      try {
        return await MySqlConnection.connect(_settings).whenComplete(() {
          if (connectInit != null) {
            connectInit!(this);
          }
        });
      } catch (e) {
        _errorLog('MySQL: connect error' + e.toString());
        close();
        rethrow;
      }
    });
  }

  ///isConnectionAlive
  Future<bool> isConnectionAlive() async {
    try {
      await (await conn).query('select 1', []).timeout(
          Duration(milliseconds: 500), onTimeout: () {
        throw TimeoutException('test isConnectionAlive timeout.');
      });
      return true;
    } catch (e) {
      conn = createConnection();
      return false;
    }
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
    var res = 0;
    table = _tableParse(table);
    var whp = _whereParse(where);
    var _where = whp['where'];
    var _values = whp['values'];
    try {
      var results =
          await query('delete from $table $_where ', _values, debug: debug);
      res = results.affectedRows ?? 0;
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
    var res = 0;
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
      var affectedRows = results.affectedRows;
      if (affectedRows! > 0) {
        res = affectedRows;
      } else {
        res = 1;
      }
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
  Future<int> insertAll({
    required String table,
    required List<Map> insertData,
    replace = false,
    debug = false,
  }) async {
    table = _tableParse(table);
    if (insertData.isEmpty) {
      throw ('insertData isEmpty');
    }
    if (insertData is List && insertData.isNotEmpty) {
      var _vals = <Object?>[];
      var _keys = '';
      var _wh = '';
      insertData[0].forEach((key, value) {
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

        return results.length;
      } catch (e) {
        _errorLog(e.toString());
        close();
      }
    }
    return 0;
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
    debug = false,
  }) async {
    table = _tableParse(table);
    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }
    if (insertData is Map && insertData.isNotEmpty) {
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
            'INSERT INTO $table ($_keys) VALUES ($_wh)', _vals,
            debug: debug);
        return result.insertId ?? 0;
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

      return _resultFormat(results)[0]['_count'];
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

      return _resultFormat(results)[0]['_avg'];
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

      return _resultFormat(results)[0]['_max'];
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

      return _resultFormat(results)[0]['_min'];
    } catch (e) {
      _errorLog(e.toString());
      close();
      return 0;
    }
  }

  ///```
  /// await db.select(
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
  /// await db.find(
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
      return res[0];
    } else {
      return {};
    }
  }

  String _tableParse(String table) {
    var _table = '';
    if (table.contains(',')) {
      _table = table;
    } else {
      if (table.contains(_prefix)) {
        _table = '`' + table + '`';
      } else {
        _table = '`' + _prefix + table + '`';
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

  void close() async {
    _sync.clear();
  }

  List<dynamic> _resultFormat(Results results) {
    var _data = [];
    if (results.isNotEmpty) {
      var f = [];
      results.fields.forEach((element) {
        f.add(element.name);
      });
      var d = [];
      for (var row in results) {
        var sd = <String, dynamic>{};
        for (var i = 0; i < f.length; i++) {
          if (row[i] is Blob) {
            sd[f[i]] = row[i].toString();
          } else {
            sd[f[i]] = row[i];
          }
        }
        d.add(sd);
      }
      _data = d;
    }
    return _data;
  }

  Map _whereParse(dynamic where) {
    var _where = '';
    var _values = [];
    if (where is String && where != '') {
      _where = '_where $where';
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
  Future<Results> query(String sql, List<Object?>? values,
      {debug = false}) async {
    var queryStr = '$sql  $values';
    queryTimes++;
    if (debug) _sqlLog(queryStr);
    var res = await (await conn).query(sql, values);
    return res;
  }

  ///queryMulti
  Future<List<Results>> queryMulti(String sql, Iterable<List<Object?>> values,
      {debug = false}) async {
    var queryStr = '$sql  $values';
    queryTimes++;
    if (debug) _sqlLog(queryStr);
    var res = await (await conn).queryMulti(sql, values);
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
