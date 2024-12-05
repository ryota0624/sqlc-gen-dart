import 'package:postgres/postgres.dart';

class QueryParameter {
  final bool ignoreRows;
  final QueryMode? queryMode;
  final Duration? timeout;

  const QueryParameter({
    required this.ignoreRows,
    required this.queryMode,
    required this.timeout,
  });

  static const QueryParameter defaultParameter = QueryParameter(
    ignoreRows: false,
    queryMode: null,
    timeout: null,
  );
}
