import 'package:sqlc_dart/sqlc_dart.dart';
import 'package:postgres/postgres.dart';

class PostgresBackend extends Backend<Session> {
  const PostgresBackend();

  @override
  PostgresQueryExecuteOption defaultParameter() => PostgresQueryExecuteOption(
        timeout: null,
        ignoreRows: false,
        queryMode: null,
      );

  @override
  Future<List<List<Object?>>> execute(
    covariant PostgresBackendSession session,
    String query,
    List<Object> queryParameters,
    covariant PostgresQueryExecuteOption option,
  ) async {
    final result = await session.session.execute(
      query,
      parameters: queryParameters,
      timeout: option.timeout,
      ignoreRows: option.ignoreRows,
      queryMode: option.queryMode,
    );
    return result.map((row) => row.toList()).toList();
  }

  @override
  BackendSession session(covariant Session session) {
    return PostgresBackendSession(session, this);
  }
}

class PostgresBackendSession extends BackendSession {
  final Session session;
  @override
  final PostgresBackend backend;

  PostgresBackendSession(
    this.session,
    this.backend,
  );
}

class PostgresQueryExecuteOption implements QueryExecuteOption {
  static const defaultValue = PostgresQueryExecuteOption(
    timeout: null,
    ignoreRows: false,
    queryMode: null,
  );

  final Duration? timeout;
  final bool ignoreRows;
  final QueryMode? queryMode;

  const PostgresQueryExecuteOption({
    required this.timeout,
    required this.ignoreRows,
    required this.queryMode,
  });
}
