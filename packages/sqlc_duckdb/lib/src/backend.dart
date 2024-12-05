import 'package:sqlc_dart/sqlc_dart.dart';
import 'package:duckdb_dart/duckdb_dart.dart';

class DuckdbBackendBackend extends Backend<Connection> {
  const DuckdbBackendBackend();

  @override
  DuckdbQueryExecuteOption defaultParameter() => DuckdbQueryExecuteOption();

  @override
  Future<List<List<Object?>>> execute(
    covariant DuckdbBackendSession session,
    String query,
    List<Object> queryParameters,
    covariant DuckdbQueryExecuteOption option,
  ) async {
    return session.connection.fetchRows(query, (row) => row);
  }

  @override
  BackendSession session(covariant Connection session) {
    return DuckdbBackendSession(session, this);
  }
}

class DuckdbBackendSession extends BackendSession {
  final Connection connection;
  @override
  final DuckdbBackendBackend backend;

  DuckdbBackendSession(
    this.connection,
    this.backend,
  );
}

class DuckdbQueryExecuteOption implements QueryExecuteOption {
  const DuckdbQueryExecuteOption();
}
