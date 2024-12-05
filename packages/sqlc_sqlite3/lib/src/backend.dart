import 'package:sqlc_dart/sqlc_dart.dart';
import 'package:sqlite3/sqlite3.dart';

class Sqlite3Backend extends Backend<Database> {
  const Sqlite3Backend();

  @override
  Sqlite3QueryExecuteOption defaultParameter() => Sqlite3QueryExecuteOption();

  @override
  Future<List<List<Object?>>> execute(
    covariant Sqlite3BackendSession session,
    String query,
    List<Object> queryParameters,
    covariant Sqlite3QueryExecuteOption option,
  ) async {
    final result = session.database.select(query, queryParameters);
    return result.map((row) => row.values).toList();
  }

  @override
  BackendSession session(covariant Database session) {
    return Sqlite3BackendSession(session, this);
  }
}

class Sqlite3BackendSession extends BackendSession {
  final Database database;
  @override
  final Sqlite3Backend backend;

  Sqlite3BackendSession(
    this.database,
    this.backend,
  );
}

class Sqlite3QueryExecuteOption implements QueryExecuteOption {
  const Sqlite3QueryExecuteOption();
}
