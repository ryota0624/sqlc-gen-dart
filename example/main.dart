import 'dart:math';

import 'package:postgres/postgres.dart';
import 'package:sqlc_dart/sqlc_dart.dart';
import 'package:sqlc_postgres_dart/sqlc_dart_postgres.dart';

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
  final a = GetReplyIds(be.session(conn))(
    parentId: '1',
  );
  await createPost(
    conn,
    id: Random().nextDouble().toString(),
    parentId: Random().nextDouble().toString(),
    content: PostContent('Hello'),
    star: 100,
  );

  final posts = await listPosts(conn);
  for (var post in posts) {
    print(post.toString());
    print('\n');
  }
  await conn.close();
}
