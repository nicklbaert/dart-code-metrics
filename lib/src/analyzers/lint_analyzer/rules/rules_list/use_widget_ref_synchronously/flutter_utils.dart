import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

_Flutter _flutterInstance = _Flutter(
  'flutter_riverpod',
  'package:flutter_riverpod',
);

_Flutter get _flutter => _flutterInstance;

bool isWidgetRef(DartType? type, {bool skipNullable = false}) =>
    _flutter.isWidgetRef(type, skipNullable: skipNullable);

/// A utility class for determining whether a given element is an expected
/// Flutter element.
///
/// See pkg/analysis_server/lib/src/utilities/flutter.dart.
class _Flutter {
  static const _nameWidgetRef = 'WidgetRef';

  final String packageName;

  final Uri _uriFramework;

  _Flutter(this.packageName, String uriPrefix)
      : _uriFramework = Uri.parse('$uriPrefix/src/consumer.dart');

  bool isWidgetRef(DartType? type, {bool skipNullable = false}) {
    if (type is! InterfaceType) {
      return false;
    }
    if (skipNullable && type.nullabilitySuffix == NullabilitySuffix.question) {
      return false;
    }

    return isExactly(type.element, _nameWidgetRef, _uriFramework);
  }

  /// Whether [element] is exactly the element named [type], from Flutter.
  bool isExactly(InterfaceElement element, String type, Uri uri) =>
      element.name == type && element.source.uri == uri;
}
