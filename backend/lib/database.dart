// lib/database.dart
import 'dart:io';
import 'package:postgres/postgres.dart';

class DatabaseClient {
  static Connection? _connection;

  static Future<Connection> get connection async {
    if (_connection != null) {
      return _connection!;
    }

    // Railway injects these environment variables out-of-the-box when
    // a PostgreSQL service is attached to your application container.
    final host = Platform.environment['PGHOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['PGPORT'] ?? '5432');
    final databaseName = Platform.environment['PGDATABASE'] ?? 'postgres';
    final username = Platform.environment['PGUSER'] ?? 'postgres';
    final password = Platform.environment['PGPASSWORD'] ?? 'postgres';

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: databaseName,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.require, // Required for secure cloud communication
      ),
    );

    // Bootstrap table initialization if it does not exist
    await _initializeTables(_connection!);

    return _connection!;
  }

  static Future<void> _initializeTables(Connection conn) async {
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        is_completed BOOLEAN NOT NULL DEFAULT FALSE,
        scheduled_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
  }
}