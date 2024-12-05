import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import 'package:sqlc_dart/sqlc_dart.dart';
import './domain_types.dart';

typedef RowGetReplyIds = String;

///  getReplyIds :many
Future<List<RowGetReplyIds>> getReplyIds(
  Session session, {
  required String parentId,
  QueryParameter queryParameter = QueryParameter.defaultParameter,
}) async {
  
  final result = await session.execute("""
    select id
from post
where parent_id = \$1
  """,
      ignoreRows: queryParameter.ignoreRows,
      queryMode: queryParameter.queryMode,
      timeout: queryParameter.timeout,
      parameters: [
        parentId,
      ]);
  return result.cast<RowGetReplyIds>();
}
class RowGetPost extends RowBase {
  // psql: text
  final String id;
  // psql: text
  final String parentId;
  // psql: post_content
  final PostContent content;

  @visibleForTesting
  Map<String, Object?> toFieldMap() => {
    'id': id,
    'parent_id': parentId,
    'content': content,
  };

  RowGetPost({
    required this.id,
    required this.parentId,
    required this.content,
  });

  factory RowGetPost.fromQueryResult(ResultRow row) {
    return RowGetPost(
      id: row[0] as String,
      parentId: row[1] as String,
      content: PostContent.fromQueryResult(row[2]),
    );
  }
}

///  getPost :one
Future<RowGetPost?> getPost(
  Session session, {
  required String id,
  QueryParameter queryParameter = QueryParameter.defaultParameter,
}) async {
  
  final result = await session.execute("""
    select id, parent_id, content
from post
where id = \$1
  """,
      ignoreRows: queryParameter.ignoreRows,
      queryMode: queryParameter.queryMode,
      timeout: queryParameter.timeout,
      parameters: [
        id,
      ]);
  if (result.isNotEmpty) {
    return RowGetPost.fromQueryResult(result.first);
  }
  return null;
}
class RowListPosts extends RowBase {
  // psql: text
  final String id;
  // psql: text
  final String parentId;
  // psql: post_content
  final PostContent content;
  // psql: int4 nullable
  final Object? star;

  @visibleForTesting
  Map<String, Object?> toFieldMap() => {
    'id': id,
    'parent_id': parentId,
    'content': content,
    'star': star,
  };

  RowListPosts({
    required this.id,
    required this.parentId,
    required this.content,
    required this.star,
  });

  factory RowListPosts.fromQueryResult(ResultRow row) {
    return RowListPosts(
      id: row[0] as String,
      parentId: row[1] as String,
      content: PostContent.fromQueryResult(row[2]),
      star: row[3] as Object,
    );
  }
}

///  listPosts :many
Future<List<RowListPosts>> listPosts(
  Session session, {
  QueryParameter queryParameter = QueryParameter.defaultParameter,
}) async {
  
  final result = await session.execute("""
    select id, parent_id, content, star
from post
  """,
      ignoreRows: queryParameter.ignoreRows,
      queryMode: queryParameter.queryMode,
      timeout: queryParameter.timeout,
      parameters: [
      ]);
  return result.map(RowListPosts.fromQueryResult).toList();
}
class RowCreatePost extends RowBase {
  // psql: text
  final String id;
  // psql: text
  final String parentId;
  // psql: post_content
  final PostContent content;
  // psql: int4 nullable
  final Object? star;

  @visibleForTesting
  Map<String, Object?> toFieldMap() => {
    'id': id,
    'parent_id': parentId,
    'content': content,
    'star': star,
  };

  RowCreatePost({
    required this.id,
    required this.parentId,
    required this.content,
    required this.star,
  });

  factory RowCreatePost.fromQueryResult(ResultRow row) {
    return RowCreatePost(
      id: row[0] as String,
      parentId: row[1] as String,
      content: PostContent.fromQueryResult(row[2]),
      star: row[3] as Object,
    );
  }
}

///  createPost :exec
Future<void> createPost(
  Session session, {
  required String id,
  required String parentId,
  required PostContent content,
  required Object star,
  QueryParameter queryParameter = QueryParameter.defaultParameter,
}) async {
  await session.execute("""
    insert into post (id, parent_id, content, star)
values (\$1, \$2, \$3, \$4)
returning id, parent_id, content, star
  """,
      ignoreRows: queryParameter.ignoreRows,
      queryMode: queryParameter.queryMode,
      timeout: queryParameter.timeout,
      parameters: [
        id,
        parentId,
        content.asSqlType(),
        star,
      ]);
  return;
}
class RowListArrayAndJson extends RowBase {
  // psql: text nullable
  final String? name;
  // psql: int4[] nullable
  final Object? intArray;
  // psql: text[][] nullable
  final String? textArrayArray;
  // psql: json nullable
  final Object? jsonData;

  @visibleForTesting
  Map<String, Object?> toFieldMap() => {
    'name': name,
    'int_array': intArray,
    'text_array_array': textArrayArray,
    'json_data': jsonData,
  };

  RowListArrayAndJson({
    required this.name,
    required this.intArray,
    required this.textArrayArray,
    required this.jsonData,
  });

  factory RowListArrayAndJson.fromQueryResult(ResultRow row) {
    return RowListArrayAndJson(
      name: row[0] as String,
      intArray: row[1] as Object,
      textArrayArray: row[2] as String,
      jsonData: row[3] as Object,
    );
  }
}

///  listArrayAndJson :many
Future<List<RowListArrayAndJson>> listArrayAndJson(
  Session session, {
  QueryParameter queryParameter = QueryParameter.defaultParameter,
}) async {
  
  final result = await session.execute("""
    select name, int_array, text_array_array, json_data
from array_and_json
  """,
      ignoreRows: queryParameter.ignoreRows,
      queryMode: queryParameter.queryMode,
      timeout: queryParameter.timeout,
      parameters: [
      ]);
  return result.map(RowListArrayAndJson.fromQueryResult).toList();
}
