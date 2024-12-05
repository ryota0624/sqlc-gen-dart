abstract class Backend<InnerSession> {
  const Backend();

  QueryExecuteOption defaultParameter();

  Future<List<List<Object?>>> execute(
    BackendSession session,
    String query,
    List<Object> queryParameters,
    QueryExecuteOption option,
  );

  BackendSession session(InnerSession session);
}

abstract class BackendSession {
  Backend get backend;
}

abstract class QueryExecuteOption {}
