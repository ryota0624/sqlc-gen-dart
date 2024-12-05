import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

abstract class RowBase {
  @visibleForOverriding
  Map<String, Object?> toFieldMap();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RowBase) return false;
    if (runtimeType != other.runtimeType) return false;
    return DeepCollectionEquality().equals(toFieldMap(), other.toFieldMap());
  }

  @override
  int get hashCode {
    return DeepCollectionEquality().hash(toFieldMap());
  }

  @override
  String toString() {
    return "${runtimeType.toString()}(${toFieldMap().toString()})";
  }
}
