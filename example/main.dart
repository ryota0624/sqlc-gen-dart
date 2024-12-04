import 'dart:math';

import 'package:postgres/postgres.dart';

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

  await createPost(
    conn,
    id: Random().nextDouble().toString(),
    parentId:  Random().nextDouble().toString(),
    content: PostContent('Hello'),
    star: 100,
  );

  final posts = await listPosts(conn);
  for (var post in posts) {
    print(post.id);
    print(post.parentId);
    print(post.content);
    print(post.star);
    print('\n');
  }
  await conn.close();
}
