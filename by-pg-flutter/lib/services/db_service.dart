import 'package:postgres/postgres.dart';

/// PostgreSQL-Service für test2view und buchpos (wie C# by-pg-grid).
class DbService {
  static const String host = '192.168.207.160';
  static const int port = 5432;
  static const String database = 'RK2';
  static const String username = 'postgres';
  static const String password = 'Ole1brumm';

  static Endpoint get _endpoint => Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      );

  static ConnectionSettings get _settings => ConnectionSettings(
        sslMode: SslMode.disable,
      );

  /// Lädt alle Zeilen aus public.test2view.
  static Future<List<Map<String, dynamic>>> loadTest2View() async {
    final conn = await Connection.open(_endpoint, settings: _settings);
    try {
      final result = await conn.execute(
        Sql.named('SELECT * FROM public.test2view'),
      );
      return result.map((row) => row.toColumnMap()).toList();
    } finally {
      await conn.close();
    }
  }

  /// Lädt alle Zeilen aus public.buchpos (für Update).
  static Future<List<Map<String, dynamic>>> loadBuchpos() async {
    final conn = await Connection.open(_endpoint, settings: _settings);
    try {
      final result = await conn.execute(
        Sql.named('SELECT * FROM public.buchpos'),
      );
      return result.map((row) => row.toColumnMap()).toList();
    } finally {
      await conn.close();
    }
  }

  /// UPDATE buchpos für eine Zeile (wie ButtonSavePreview / update row).
  static Future<void> updateBuchposRow({
    required int pk1,
    required String? bvh,
    required String? test,
    required double betrag,
    required String? art,
    required String? gewerk,
  }) async {
    final conn = await Connection.open(_endpoint, settings: _settings);
    try {
      await conn.execute(
        Sql.named(
          'UPDATE public.buchpos SET bvh = @bvh, test = @test, betrag = @betrag, art = @art, gewerk = @gewerk WHERE pk1 = @pk1',
        ),
        parameters: {
          'bvh': bvh,
          'test': test,
          'betrag': betrag,
          'art': art,
          'gewerk': gewerk,
          'pk1': pk1,
        },
      );
    } finally {
      await conn.close();
    }
  }
}
