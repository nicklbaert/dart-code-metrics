// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// String utilities that use underlying ASCII codes for improved performance.
/// Ultimately we should consider carefully when we use RegExps where a simple
/// loop would do (and would do so far more performantly).
/// See: https://github.com/dart-lang/linter/issues/1828
library;

import 'charcodes.dart';

/// Return `true` if the given [character] is the ASCII '.' character.
bool isDot(int character) => character == $dot;

/// Return `true` if the given [character] is a lowercase ASCII character.
bool isLowerCase(int character) => character >= $chara && character <= $charz;

/// Return `true` if the given [character] an ASCII number character.
bool isNumber(int character) => character >= 48 && character <= 57;

/// Return `true` if the given [character] is the ASCII '_' character.
bool isUnderScore(int character) => character == $char_;

/// Check if the given [name] is a valid Dart filename.
///
/// Files with a strict `.dart` extension are required to use:
/// * lower_case_with_underscores and are
/// * limited to valid Dart identifiers
///
/// (Files without a strict `.dart` extension are considered valid.)
bool isValidDartFileName(String name) {
  if (name.length < 6 || !name.endsWith('.dart')) {
    return true;
  }

  final length = name.length - 5;
  for (var runIdx = 1; runIdx < length - 1; ++runIdx) {
    final character = name.codeUnitAt(runIdx);
    // Indicates a prefixed suffix (like `.g.dart`) which is considered a
    // non-strict Dart filename.
    if (isDot(character)) {
      return true;
    }
  }

  for (var runIdx = 0; runIdx < length; ++runIdx) {
    final character = name.codeUnitAt(runIdx);
    if (!isLowerCase(character) && !isUnderScore(character)) {
      if (isNumber(character)) {
        if (runIdx == 0) {
          return false;
        }
        continue;
      }

      return false;
    }
  }

  return true;
}

extension StringExtensions on String {
  /// Returns `true` if `this` has a leading `_`.
  bool get hasLeadingUnderscore => startsWith('_');

  /// Returns whether `this` is just underscores.
  bool get isJustUnderscores {
    if (isEmpty) {
      return false;
    }
    switch (length) {
      case 1:
        return this == '_';
      case 2:
        return this == '__';
      default:
        for (var i = 0; i < length; i++) {
          if (!isUnderScore(codeUnitAt(i))) {
            return false;
          }
        }
        return true;
    }
  }
}
