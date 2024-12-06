import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:postgres/postgres.dart';
import 'package:sqlc_dart/sqlc_dart.dart';
import 'package:sqlc_postgres_dart/sqlc_dart_postgres.dart';
import 'package:sqlc_sqlite3_dart/sqlc_dart_sqlite3.dart';
import 'package:sqlc_duckdb_dart/sqlc_dart_duckdb.dart';
import 'package:duckdb_dart/duckdb_dart.dart' as d;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'generated/domain_types.dart';
import 'generated/query.dart';
import 'generated_sqlite/query.dart' as sqlite;

void main() async {
  final loggingError = (result) {
    IO<void>(() {
      result.getLeft().map((errors) {
        print('error');
        print(errors);
      });
    }).run();
  };

  await usingConnection(() async {
    return await Connection.open(
      Endpoint(
          host: 'localhost',
          database: 'dev',
          username: 'user',
          password: 'password',
          port: 4206),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
  }, (conn) {
    final be = PostgresBackend();
    return _doPostWithPostgresSyntax(be.session(conn));
  }, (conn) async {
    await conn.close();
  }).run().then(loggingError);

  await usingConnection(() async {
    return d.Connection('sql/example.duckdb');
  }, (conn) {
    final duckdb = DuckdbBackend().session(d.Connection('example.duckdb'));
    return _doPostWithPostgresSyntax(duckdb);
  }, (conn) async {
    conn.close();
  }).run().then(loggingError);

  await usingConnection(() async {
    return sqlite.sqlite3.open('sql/example.sqlite3');
  }, (conn) {
    return _doPostWithSqlite3Syntax(Sqlite3Backend().session(conn));
  }, (conn) async {
    conn.dispose();
  }).run().then(loggingError);
}

TaskEither<List<dynamic>, void> usingConnection<C>(
  Future<C> Function() prepareConnection,
  TaskEither<dynamic, dynamic> Function(C) execute,
  Future<void> Function(C) closeConnection,
) {
  final connectionT = TaskEither.tryCatch(prepareConnection, ((e, _) => [e]));
  final resultT = connectionT.flatMap(
    (conn) {
      final closeConnectionT = TaskEither.tryCatch(() async {
        print('closing connection');
        return closeConnection(conn);
      }, (e, _) => [e]);

      return execute(conn).flatMap((_) {
        return closeConnectionT;
      }).orElse(
        (e) => closeConnectionT
            .flatMap(
              (_) => TaskEither.left([e]),
            )
            .mapLeft(
              (closeErr) => [e, closeErr],
            ),
      );
    },
  );

  return resultT;
}

TaskEither<dynamic, void> _doPostWithPostgresSyntax(BackendSession session) {
  final createT = TaskEither.tryCatch(() async {
    return await CreatePost(session)(
      parentId: '1',
      content: PostContent('content'),
      id: Random().nextInt(100000000).toString(),
      star: 100,
    );
  }, (e, _) => e);
  final listT = TaskEither.tryCatch(() async {
    final posts2 = await ListPosts(session)();
    for (var post in posts2) {
      print(post.toString());
      print('\n');
    }
    return;
  }, (e, _) => e);
  return TaskEither<void, dynamic>.Do(($) async {
    await $(createT);
    return await $(listT);
  });
}

TaskEither<dynamic, void> _doPostWithSqlite3Syntax(BackendSession session) {
  final a = TaskEither<dynamic, void>.tryCatch(() async {
    await sqlite.CreatePost(session)(
      parentId: '1',
      content: 'content',
      id: Random().nextInt(100000000).toString(),
      star: 100,
    );
  }, (e, _) => e);

  final b = TaskEither.tryCatch(() async {
    final posts2 = await sqlite.ListPosts(session)();
    for (var post in posts2) {
      print(post.toString());
      print('\n');
    }
    return;
  }, (e, _) => e);

  return a.andThen<void>(() => b);
}
