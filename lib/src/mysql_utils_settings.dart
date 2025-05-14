import 'dart:io';

class MysqlUtilsSettings {
  /// The hostname of the MySQL server, defaults to localhost.
  final String host;

  /// The port of the MySQL server, defaults to 3306.
  final int port;

  /// The username to use when connecting to the MySQL server.
  final String user;

  /// The password to use when connecting to the MySQL server.
  final String password;

  /// The database to use when connecting to the MySQL server.
  final String db;

  /// The maximum number of connections to keep open, defaults to 1000.
  final int maxConnections;

  /// Whether to use secure connections, defaults to true.
  final bool secure;

  /// The prefix for tables, defaults to empty string.
  final String prefix;

  /// Whether to use connection pooling, defaults to false.
  final bool pool;

  /// The collation for the database, defaults to utf8mb4_general_ci.
  final String collation;

  /// The timeout for queries, defaults to 10000.
  final int timeoutMs;

  /// Whether to escape SQL, defaults to true.
  final bool sqlEscape;

  /// Whether to log SQL, defaults to false.
  final bool debug;

  /// SSL security context.
  /// ```
  /// final SecurityContext securityContext = SecurityContext(withTrustedRoots: true);
  /// securityContext.useCertificateChain('path/to/client_cert.pem');
  /// securityContext.usePrivateKey('path/to/client_key.pem');
  /// securityContext.setTrustedCertificates('path/to/ca_cert.pem');
  /// ```
  final SecurityContext? securityContext;

  /// bad certificate handler.
  /// ```
  /// onBadCertificate: (certificate) => true,
  /// ```
  final bool Function(X509Certificate)? onBadCertificate;

  MysqlUtilsSettings({
    this.host = 'localhost',
    this.port = 3306,
    this.user = '',
    this.password = '',
    this.db = '',
    this.maxConnections = 1000,
    this.secure = true,
    this.prefix = '',
    this.pool = false,
    this.collation = 'utf8mb4_general_ci',
    this.timeoutMs = 10000,
    this.sqlEscape = true,
    this.debug = false,
    this.securityContext,
    this.onBadCertificate,
  });
}
