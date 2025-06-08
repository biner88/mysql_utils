import 'dart:async';
import 'package:mysql_client_plus/mysql_client_plus.dart';
import 'package:mysql_utils/mysql_utils.dart';

///mysql helper
class MysqlUtils {
  ///pool connect
  late Future<MySQLConnectionPool> poolConn;

  ///single connect
  late Future<MySQLConnection> singleConn;

  ///mysql setting
  late MysqlUtilsSettings _settings;

  ///query Times
  int queryTimes = 0;

  ///transaction start
  int transTimes = 0;

  ///sql error log
  final Function? errorLog;

  /// show sql log
  final Function? sqlLog;

  /// sqlEscape
  bool sqlEscape = false;

  ///
  final Function? connectInit;
  factory MysqlUtils({
    required MysqlUtilsSettings settings,
    Function? errorLog,
    Function? sqlLog,
    Function? connectInit,
  }) {
    return MysqlUtils._internal(settings, sqlLog, errorLog, connectInit);
  }

  MysqlUtils._internal([
    MysqlUtilsSettings? settings,
    this.sqlLog,
    this.errorLog,
    this.connectInit,
  ]) {
    _settings = settings!;
    if (settings.pool) {
      poolConn = createConnectionPool(settings);
    } else {
      singleConn = createConnectionSingle(settings);
    }
  }

  ///create single connection
  Future<MySQLConnection> createConnectionSingle(MysqlUtilsSettings settings) async {
    final conn = await MySQLConnection.createConnection(
      host: settings.host,
      port: settings.port,
      userName: settings.user,
      password: settings.password,
      databaseName: settings.db,
      secure: settings.secure,
      collation: settings.collation,
      securityContext: settings.securityContext,
      onBadCertificate: settings.onBadCertificate,
    );
    await conn.connect();
    return conn;
  }

  ///create pool connection
  Future<MySQLConnectionPool> createConnectionPool(MysqlUtilsSettings settings) async {
    return MySQLConnectionPool(
      host: settings.host,
      port: settings.port,
      userName: settings.user,
      password: settings.password,
      databaseName: settings.db,
      maxConnections: settings.maxConnections,
      timeoutMs: settings.timeoutMs,
      secure: settings.secure,
      collation: settings.collation,
      securityContext: settings.securityContext,
      onBadCertificate: settings.onBadCertificate,
    );
  }

  ///isConnectionAlive
  Future<bool> isConnectionAlive() async {
    try {
      await query('select 1').timeout(Duration(milliseconds: 500), onTimeout: () {
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
      transTimes++;
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
  Future<BigInt> delete({
    required String table,
    required where,
    bool debug = false,
  }) async {
    table = _tableParse(table);
    List _whereAndValues = _whereParse(where);
    ResultFormat results = await query('DELETE FROM $table ${_whereAndValues.first} ', debug: debug, whereValues: _whereAndValues.last, isStmt: true);
    return results.affectedRows;
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
  Future<BigInt> update({
    required String table,
    required Map<String, dynamic> updateData,
    required where,
    bool debug = false,
  }) async {
    table = _tableParse(table);
    List _whereAndValues = _whereParse(where);
    if (updateData.isEmpty) {
      throw ('updateData.length!=0');
    }

    List<String> _setkeys = [];
    List values = [];
    updateData.forEach((key, value) {
      _setkeys.add('`$key` = ?');
      values.add(value);
    });
    values.addAll(_whereAndValues.last);

    String _setValue = _setkeys.join(',');
    String _sql = 'UPDATE $table SET $_setValue ${_whereAndValues.first}';
    ResultFormat results = await query(_sql, whereValues: values, debug: debug, isStmt: true);
    return results.affectedRows;
  }

  ///
  /// return affectedRows
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

  Future<BigInt> insertAll({
    required String table,
    required List<Map<String, dynamic>> insertData,
    bool replace = false,
    bool debug = false,
  }) async {
    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }

    table = _tableParse(table);

    final firstRow = insertData.first;
    final fields = firstRow.keys.toList();
    final placeholders = List.filled(fields.length, '?').join(',');
    final fieldsString = fields.map((k) => '`$k`').join(',');

    final valuesPlaceholder = List.filled(insertData.length, '($placeholders)').join(',');

    final values = <dynamic>[];
    for (final row in insertData) {
      for (final field in fields) {
        values.add(row[field]);
      }
    }

    final sql = '${replace ? 'REPLACE' : 'INSERT'} INTO $table ($fieldsString) VALUES $valuesPlaceholder';

    final result = await query(sql, whereValues: values, debug: debug, isStmt: true);
    return result.affectedRows;
  }

  ///```
  /// return lastInsertID
  ///
  /// await db.insert(
  ///   table: 'table',
  ///   insertData: {
  ///     'telphone': '+113888888888',
  ///     'create_time': 1620577162252,
  ///     'update_time': 1620577162252,
  ///   },
  /// );
  ///```
  Future<BigInt> insert({
    required String table,
    required Map<String, dynamic> insertData,
    bool replace = false,
    bool debug = false,
  }) async {
    if (insertData.isEmpty) {
      throw ArgumentError('insertData cannot be empty');
    }

    table = _tableParse(table);

    final fields = insertData.keys.map((k) => '`$k`').toList();
    final values = insertData.values.toList();
    final placeholders = List.filled(fields.length, '?');

    final sql = '${replace ? 'REPLACE' : 'INSERT'} INTO $table '
        '(${fields.join(',')}) VALUES (${placeholders.join(',')})';

    final result = await query(sql, whereValues: values, debug: debug, isStmt: true);
    return result.lastInsertID;
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
    String fields = '*',
    Map<String, dynamic> where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    double res = await _keyMaxMinAvgCount(table: table, fields: fields, where: where, group: group, having: having, debug: debug, sqlKey: 'COUNT', sqlValue: '_count');
    return res.toInt();
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
    required String fields,
    Map<String, dynamic> where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    return _keyMaxMinAvgCount(table: table, fields: fields, where: where, group: group, having: having, debug: debug, sqlKey: 'AVG', sqlValue: '_avg');
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
    required String fields,
    Map<String, dynamic> where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    return _keyMaxMinAvgCount(table: table, fields: fields, where: where, group: group, having: having, debug: debug, sqlKey: 'MAX', sqlValue: '_max');
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
    required String fields,
    Map<String, dynamic> where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    return _keyMaxMinAvgCount(table: table, fields: fields, where: where, group: group, having: having, debug: debug, sqlKey: 'MIN', sqlValue: '_min');
  }

  Future<double> _keyMaxMinAvgCount({
    required String table,
    required String fields,
    required String sqlKey,
    required String sqlValue,
    Map<String, dynamic> where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    if (fields.isEmpty) {
      throw ArgumentError('fields cannot be empty');
    }

    table = _tableParse(table);
    final whereResult = _whereParse(where);
    final whereClause = whereResult.first;
    final whereValues = whereResult.last;
    final groupClause = group.isNotEmpty ? ' GROUP BY $group' : '';
    final havingClause = having.isNotEmpty ? ' HAVING $having' : '';
    final sql = 'SELECT $sqlKey($fields) AS $sqlValue FROM $table$whereClause$groupClause$havingClause';
    final result = await query(sql, whereValues: whereValues, debug: debug, isStmt: true);
    final rawValue = result.rows.first[sqlValue];
    if (rawValue == null) return 0.0;
    if (rawValue is num) return rawValue.toDouble();
    return double.tryParse(rawValue.toString()) ?? 0.0;
  }

  ///```
  /// await db.getAll(
  ///   table: 'table',
  ///   fields: '*',
  ///   excludeFields: 'id,name',
  ///   group: 'name',
  ///   having: 'name',
  ///   order: 'id desc',
  ///   limit: 10,//10 or '10 ,100'
  ///   debug: false,
  ///   where: {
  ///     'email': 'xxx@google.com',
  ///     'id': ['between', , 1, 4],
  ///     'email2': ['=', 'sss@google.com'],
  ///     'news_title': ['like', '%name%'],
  ///     'user_id': ['>', 1],
  ///     '_SQL': '(`isNet`=1 OR `isNet`=2)',
  ///   },
  ///   //where:'`id`=1 AND name like "%jame%"',
  /// );
  ///```
  Future<List<dynamic>> getAll({
    required String table,
    String fields = '*',
    String excludeFields = '',
    where = const {},
    String order = '',
    dynamic limit = '',
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (order != '') order = 'ORDER BY $order';

    List _whereAndValues = _whereParse(where);
    table = _tableParse(table);
    limit = _limitParse(limit);

    String _sql = 'SELECT $fields FROM $table ${_whereAndValues.first} $group $having $order $limit';

    ResultFormat results = await query(_sql, debug: debug, whereValues: _whereAndValues.last, isStmt: true, excludeFields: excludeFields);

    if (results.numOfRows > 0) {
      return results.rows;
    } else {
      return [];
    }
  }

  ///```
  /// await db.getOne(
  ///   table: 'table',
  ///   fields: '*',
  ///   excludeFields: 'id,name',
  ///   group: 'name',
  ///   having: 'name',
  ///   order: 'id desc',
  ///   debug: false,
  ///   where: {
  ///     'email': 'xxx@google.com',
  ///     'id': ['between', , 1, 4],
  ///     'email2': ['=', 'sss@google.com'],
  ///     'news_title': ['like', '%name%'],
  ///     'user_id': ['>', 1],
  ///     '_SQL': '(`isNet`=1 OR `isNet`=2)',
  ///   },
  ///   //where:'`id`=1 AND name like "%jame%"',
  /// );
  ///```
  Future<Map> getOne({
    required String table,
    String fields = '*',
    String excludeFields = '',
    where = const {},
    String group = '',
    String having = '',
    String order = '',
    bool debug = false,
  }) async {
    List<dynamic> res = await getAll(
      table: table,
      fields: fields,
      excludeFields: excludeFields,
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

  ///table parse
  String _tableParse(String table) {
    var _table = '';
    String _prefix = _settings.prefix;
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

  ///where parsw
  List _whereParse(dynamic where) {
    String whereClause = '';
    List values = [];

    if (where is String && where.isNotEmpty) {
      whereClause = 'WHERE $where';
    } else if (where is Map && where.isNotEmpty) {
      List<String> conditions = [];

      where.forEach((key, value) {
        if (key == '_SQL') {
          conditions.add(value.toString());
        } else if (value is String || value is num) {
          conditions.add('`$key` = ?');
          values.add(value);
        } else if (value is List && value.isNotEmpty) {
          final op = value[0].toString().toLowerCase();
          switch (op) {
            case 'in':
            case 'notin':
              if (value.length < 2 || value[1] is! List) break;
              final list = value[1] as List;
              final placeholders = List.filled(list.length, '?').join(', ');
              conditions.add('`$key` ${op == 'in' ? 'IN' : 'NOT IN'} ($placeholders)');
              values.addAll(list.map(sqlEscapeString));
              break;

            case 'between':
            case 'notbetween':
              if (value.length == 3) {
                conditions.add('`$key` ${op == 'between' ? 'BETWEEN' : 'NOT BETWEEN'} ? AND ?');
                values.addAll([value[1], value[2]]);
              } else if (value.length == 2 && value[1] is String) {
                final parts = (value[1] as String).split(',');
                if (parts.length == 2) {
                  conditions.add('`$key` ${op == 'between' ? 'BETWEEN' : 'NOT BETWEEN'} ? AND ?');
                  values.addAll(parts);
                }
              }
              break;

            case 'like':
            case 'notlike':
              conditions.add('`$key` ${op == 'like' ? 'LIKE' : 'NOT LIKE'} ?');
              values.add(sqlEscapeString(value[1]));
              break;

            case '>':
            case '<':
            case '=':
            case '<>':
            case '!=':
              if (value.length >= 2) {
                conditions.add('`$key` ${op} ?');
                values.add(value[1]);
              }
              break;
          }
        }
      });

      if (conditions.isNotEmpty) {
        whereClause = 'WHERE ' + conditions.join(' AND ');
      }
    }

    return [whereClause, values];
  }

  ///errorRack
  Future<void> errorRollback() async {
    if (transTimes > 0) {
      rollback();
    }
  }

  ///close
  Future<void> close() async {
    if (!_settings.pool) {
      (await singleConn).close();
    } else {
      (await poolConn).close();
    }
  }

  ///query
  Future<ResultFormat> query(
    String sql, {
    List whereValues = const [],
    String excludeFields = '',
    debug = false,
    bool isStmt = false,
  }) async {
    // Validate input
    if (sql.trim().isEmpty) {
      throw ArgumentError('SQL query cannot be empty');
    }
    // Debug logging
    if (debug || _settings.debug) {
      _sqlLog('Query: $sql');
      if (whereValues.isNotEmpty) {
        _sqlLog('Parameters: $whereValues');
      }
    }
    try {
      final connection = _settings.pool ? await poolConn : await singleConn;
      final isPool = _settings.pool;
      late IResultSet resultSet;
      if (isStmt) {
        final stmt = isPool ? await (connection as MySQLConnectionPool).prepare(sql) : await (connection as MySQLConnection).prepare(sql);
        try {
          resultSet = await stmt.execute(whereValues);
        } finally {
          // await stmt.deallocate();
        }
      } else {
        resultSet = isPool ? await (connection as MySQLConnectionPool).execute(sql) : await (connection as MySQLConnection).execute(sql);
      }
      return ResultFormat.from(resultSet, excludeFields: excludeFields);
    } catch (e, stackTrace) {
      // Enhanced error handling
      final errorMsg = 'Query failed: $sql\nError: $e\nStack trace: $stackTrace';
      _errorLog(errorMsg);

      // Attempt to rollback if in transaction
      try {
        await errorRollback();
      } catch (rollbackError) {
        _errorLog('Rollback failed: $rollbackError');
      }
      return ResultFormat.empty();
    }
  }

  ///query multi
  Future<List<int>> queryMulti(String sql, Iterable<List<Object?>> values, {debug = false}) async {
    var queryStr = '$sql $values';
    queryTimes++;
    if (debug || _settings.debug) _sqlLog(queryStr);
    PreparedStmt stmt;
    if (_settings.pool) {
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

  /// error log
  void _errorLog(String e) {
    if (errorLog != null) {
      errorLog!(e);
    } else {
      throw e;
    }
  }

  /// sql log report
  void _sqlLog(String sql) {
    if (sqlLog != null) {
      sqlLog!(sql);
    }
  }

  /// escape sql string
  dynamic sqlEscapeString(dynamic input) {
    if (input is String) {
      return input.replaceAll('\'', '\\\'');
    }
    return input;
  }
}

///Result Format
class ResultFormat {
  List cols = [];
  List rows = [];
  List rowsAssoc = [];
  BigInt affectedRows = BigInt.zero;
  int numOfRows = 0;
  int numOfColumns = 0;
  BigInt lastInsertID = BigInt.zero;
  Stream<ResultSetRow>? rowsStream;
  ResultFormat({
    required this.cols,
    required this.rows,
    required this.rowsAssoc,
    required this.affectedRows,
    required this.numOfRows,
    required this.numOfColumns,
    required this.lastInsertID,
    required this.rowsStream,
  });
  ResultFormat.from(IResultSet results, {String excludeFields = ''}) {
    List _rows = [];
    List _cols = [];
    List _rowsAssoc = [];
    List<String> _excludeFields = [];
    if (excludeFields != '') {
      excludeFields.split(',').map((element) => element.trim()).toList();
    }
    if (results.rows.isNotEmpty) {
      results.rows.forEach((e) {
        if (_excludeFields.isEmpty) {
          _rows.add(e.typedAssoc());
        } else {
          Map _row = e.typedAssoc();
          _row.removeWhere((key, value) => _excludeFields.contains(key));
          _rows.add(_row);
        }
        _rowsAssoc.add(e);
      });
    }
    if (results.cols.isNotEmpty) {
      if (_excludeFields.isEmpty) {
        results.cols.forEach((e) => _cols.add({'name': e.name, 'type': e.type}));
      } else {
        results.cols.forEach((e) {
          if (!_excludeFields.contains(e.name)) {
            _cols.add({'name': e.name, 'type': e.type});
          }
        });
      }
    }
    cols = _cols;
    rows = _rows;
    rowsAssoc = _rowsAssoc;
    affectedRows = results.affectedRows;
    numOfRows = results.numOfRows;
    numOfColumns = results.numOfColumns;
    rowsStream = results.rowsStream;
    lastInsertID = results.lastInsertID;
  }
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cols'] = cols;
    data['rows'] = rows;
    data['rowsAssoc'] = rowsAssoc;
    data['affectedRows'] = affectedRows;
    data['numOfRows'] = numOfRows;
    data['numOfColumns'] = numOfColumns;
    data['rowsStream'] = rowsStream;
    data['lastInsertID'] = lastInsertID;
    return data;
  }

  ResultFormat.empty() {
    cols = [];
    rows = [];
    affectedRows = BigInt.zero;
    rowsAssoc = [];
    numOfRows = 0;
    numOfColumns = 0;
    rowsStream = null;
    lastInsertID = BigInt.zero;
  }
}
