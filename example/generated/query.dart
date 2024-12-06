import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import 'package:sqlc_dart/sqlc_dart.dart';
import './domain_types.dart';

typedef RowGetReplyIds = String;

///  getReplyIds :many

class GetReplyIds {
  final BackendSession _session;
  GetReplyIds(this._session);
  Future<List<RowGetReplyIds>> call({
    required String parentId,
    QueryExecuteOption? queryExecuteOption,
  }) async {
    final filledQueryExecuteOption =
        queryExecuteOption ?? _session.backend.defaultParameter();

    final result = await _session.backend.execute(
        _session,
        """
  select id
from post
where parent_id = \$1
  """,
        [
          parentId,
        ],
        filledQueryExecuteOption);
    return result.cast<RowGetReplyIds>();
  }
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

  factory RowGetPost.fromQueryResult(List<Object?> row) {
    return RowGetPost(
      id: row[0] as String,
      parentId: row[1] as String,
      content: PostContent.fromQueryResult(row[2]),
    );
  }
}

///  getPost :one

class GetPost {
  final BackendSession _session;
  GetPost(this._session);
  Future<RowGetPost?> call({
    required String id,
    QueryExecuteOption? queryExecuteOption,
  }) async {
    final filledQueryExecuteOption =
        queryExecuteOption ?? _session.backend.defaultParameter();

    final result = await _session.backend.execute(
        _session,
        """
  select id, parent_id, content
from post
where id = \$1
  """,
        [
          id,
        ],
        filledQueryExecuteOption);
    if (result.isNotEmpty) {
      return RowGetPost.fromQueryResult(result.first);
    }
    return null;
  }
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

  factory RowListPosts.fromQueryResult(List<Object?> row) {
    return RowListPosts(
      id: row[0] as String,
      parentId: row[1] as String,
      content: PostContent.fromQueryResult(row[2]),
      star: row[3] as Object,
    );
  }
}

///  listPosts :many

class ListPosts {
  final BackendSession _session;
  ListPosts(this._session);
  Future<List<RowListPosts>> call({
    QueryExecuteOption? queryExecuteOption,
  }) async {
    final filledQueryExecuteOption =
        queryExecuteOption ?? _session.backend.defaultParameter();

    final result = await _session.backend.execute(
        _session,
        """
  select id, parent_id, content, star
from post
  """,
        [],
        filledQueryExecuteOption);
    return result.map(RowListPosts.fromQueryResult).toList();
  }
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

  factory RowCreatePost.fromQueryResult(List<Object?> row) {
    return RowCreatePost(
      id: row[0] as String,
      parentId: row[1] as String,
      content: PostContent.fromQueryResult(row[2]),
      star: row[3] as Object,
    );
  }
}

///  createPost :exec

class CreatePost {
  final BackendSession _session;
  CreatePost(this._session);
  Future<void> call({
    required String id,
    required String parentId,
    required PostContent content,
    required Object star,
    QueryExecuteOption? queryExecuteOption,
  }) async {
    final filledQueryExecuteOption =
        queryExecuteOption ?? _session.backend.defaultParameter();
    await _session.backend.execute(
        _session,
        """
  insert into post (id, parent_id, content, star)
values (\$1, \$2, \$3, \$4)
returning id, parent_id, content, star
  """,
        [
          id,
          parentId,
          content.asSqlType(),
          star,
        ],
        filledQueryExecuteOption);
    return;
  }
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

  factory RowListArrayAndJson.fromQueryResult(List<Object?> row) {
    return RowListArrayAndJson(
      name: row[0] as String,
      intArray: row[1] as Object,
      textArrayArray: row[2] as String,
      jsonData: row[3] as Object,
    );
  }
}

///  listArrayAndJson :many

class ListArrayAndJson {
  final BackendSession _session;
  ListArrayAndJson(this._session);
  Future<List<RowListArrayAndJson>> call({
    QueryExecuteOption? queryExecuteOption,
  }) async {
    final filledQueryExecuteOption =
        queryExecuteOption ?? _session.backend.defaultParameter();

    final result = await _session.backend.execute(
        _session,
        """
  select name, int_array, text_array_array, json_data
from array_and_json
  """,
        [],
        filledQueryExecuteOption);
    return result.map(RowListArrayAndJson.fromQueryResult).toList();
  }
}
