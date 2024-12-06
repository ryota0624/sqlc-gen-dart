import 'package:postgres/postgres.dart';
import 'package:sqlc_postgres_dart/sqlc_postgres_dart.dart';
import 'package:sqlc_duckdb_dart/sqlc_duckdb_dart.dart';

import 'package:duckdb_dart/duckdb_dart.dart' as d;
import 'generated/domain_types.dart';
import 'generated/query.dart';

void main() async {
  final conn = await Connection.open(
    Endpoint(
        host: 'localhost',
        database: 'dev',
        username: 'user',
        password: 'password',
        port: 4206),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );
  print('has connection!');
  final be = PostgresBackend();

  final posts = await ListPosts(be.session(conn))();
  for (var post in posts) {
    print(post.toString());
    print('\n');
  }
  await conn.close();

  final con = d.Connection('example.duckdb');
  final duckdb = DuckdbBackend().session(con);
  await CreatePost(duckdb)(
      parentId: '1', content: PostContent('content'), id: '1', star: 100);

  final posts2 = await ListPosts(duckdb)();
  for (var post in posts2) {
    print(post.toString());
    print('\n');
  }
  con.close();
}
