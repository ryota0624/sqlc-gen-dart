class PostContent {
  final String value;

  PostContent(this.value);

  factory PostContent.fromQueryResult(dynamic value) {
    return PostContent(value as String);
  }

  String asSqlType() {
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostContent &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'PostContent($value)';
  }
}

class PostRate {
  final int value;

  PostRate(this.value);

  factory PostRate.fromQueryResult(dynamic value) {
    return PostRate(value as int);
  }

  int asSqlType() {
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostRate &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'PostRate($value)';
  }
}
