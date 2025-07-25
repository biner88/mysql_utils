## [2.1.12]

* Update mysql_client_plus version to 0.1.2
* Add update add decrease and increase methods

```
await db.update(table: 'users', where: 'id = 1', updateData: {
  'view_count': ['inc', 1], //or ['+', 1], 
  'first_view': ['dec', 1]  //or ['-', 1], 
}); 
```

## [2.1.11]

* Fix the problem that statements were not released correctly

## [2.1.10]

* Update mysql_client_plus version to 0.1.1

## [2.1.9]

* Updated mysql_client_plus to version ^0.1.0
* Add support for binary queries on JSON data types
* Add `getOne` and `getAll` add `excludeFields` parameter

## [2.1.8]

* Add action test
* Fix the encoding problem of querying Chinese

## [2.1.7]

* Updated mysql_client_plus to version ^0.0.32
* Updated settings from `Map` to `MysqlUtilsSettings` ⚠️⚠️⚠️
* Added support for `BLOB` and `JSON` types  [#17](https://github.com/biner88/mysql_utils/issues/17)
* Added support for SSL certificates
* Added support for calling stored procedures  [#16](https://github.com/biner88/mysql_utils/issues/16)
* Added support for `sha256_password` authentication
* Added global `debug` option
* Added tests

## [2.1.6]

* Updated mysql_client_plus: ^0.0.31
* Update dependencies

## [2.1.5]

* Updated mysql_client_plus: ^0.0.30
* Updated return type int to BigInt

## [2.1.4]

* Added WHERE parameter `!=`

## [2.1.3]

* Added settings `sqlEscape: true`
* Updated README.md

## [2.1.1]

* Updated mysql_client: ^0.0.27

## [2.1.0]

* Fixed insertAll: debug = false

## [2.0.11]

* Updated mysql_client: ^0.0.24

## [2.0.10]

* Fixed _rows.

## [2.0.9]

* Clean

## [2.0.8]

* Fixed affectedRows

## [2.0.7]

* Stability improvements

## [2.0.6]

* Support special character insertion Translate

## [2.0.5]

* Fixed Multi database link.

## [2.0.4]

* Fixed transaction.

## [2.0.3]

* Fixed return data type.

## [2.0.2]

* Fixed Transactions.

## [2.0.1]

* Change Bigint to int.

## [2.0.0]

* Changed the library to mysql_client.

## [1.0.8]

* No update returned 0.

## [1.0.7]

* delete flutter sdk

## [1.0.6]

* add multi-table query
* add where support string
* merge mysql1 

## [1.0.5]

* add `notin`

## [1.0.4]

* Fix document error.

## [1.0.3]

* Fix Bug [#3](https://github.com/biner88/mysql_utils/issues/3)
* Add Where `in`,                                                                                                                                                     `between`,  `notbetween` and demo.

## [1.0.2]

* Update README.md.

## [1.0.1]

* Update README.md & pubspec.yaml. PUB POINTS to 120.

## [1.0.0]

* mysql_utils initial release. This is [mysql1](https://pub.dev/packages/mysql1) help library.
