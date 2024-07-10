// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Common AST helpers.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/workspace/workspace.dart'; // ignore: implementation_imports
import 'package:path/path.dart' as path;

import 'analyzer.dart';
import 'utils.dart';

final List<String> reservedWords = _collectReservedWords();

/// Returns direct children of [parent].
List<Element> getChildren(Element parent, [String? name]) {
  final children = <Element>[];
  visitChildren(parent, (Element element) {
    if (name == null || element.displayName == name) {
      children.add(element);
    }

    return false;
  });

  return children;
}

/// Return the compilation unit of a node
CompilationUnit? getCompilationUnit(AstNode node) =>
    node.thisOrAncestorOfType<CompilationUnit>();

/// Returns a field identifier with the given [name] in the given [decl]'s
/// variable declaration list or `null` if none is found.
Token? getFieldName(FieldDeclaration decl, String name) {
  for (final v in decl.fields.variables) {
    if (v.name.lexeme == name) {
      return v.name;
    }
  }

  return null;
}

/// Returns the most specific AST node appropriate for associating errors.
SyntacticEntity getNodeToAnnotate(Declaration node) {
  if (node is ClassDeclaration) {
    return node.name;
  }
  if (node is ClassTypeAlias) {
    return node.name;
  }
  if (node is ConstructorDeclaration) {
    return node.name ?? node.returnType;
  }
  if (node is EnumConstantDeclaration) {
    return node.name;
  }
  if (node is EnumDeclaration) {
    return node.name;
  }
  if (node is ExtensionDeclaration) {
    return node.name ?? node;
  }
  if (node is FieldDeclaration) {
    return node.fields;
  }
  if (node is FunctionDeclaration) {
    return node.name;
  }
  if (node is FunctionTypeAlias) {
    return node.name;
  }
  if (node is GenericTypeAlias) {
    return node.name;
  }
  if (node is MethodDeclaration) {
    return node.name;
  }
  if (node is MixinDeclaration) {
    return node.name;
  }
  if (node is TopLevelVariableDeclaration) {
    return node.variables;
  }
  if (node is TypeParameter) {
    return node.name;
  }
  if (node is VariableDeclaration) {
    return node.name;
  }
  if (node is ExtensionTypeDeclaration) {
    return node.name;
  }
  assert(false, "Unaccounted for Declaration subtype: '${node.runtimeType}'");

  return node;
}

/// If the [node] is the finishing identifier of an assignment, return its
/// "writeElement", otherwise return its "staticElement", which might be
/// thought as the "readElement".
Element? getWriteOrReadElement(SimpleIdentifier node) {
  final writeElement = _getWriteElement(node);
  if (writeElement != null) {
    return writeElement;
  }

  return node.staticElement;
}

/// Returns `true` if this element is the `==` method declaration.
bool isEquals(ClassMember element) =>
    element is MethodDeclaration && element.name.lexeme == '==';

/// Returns `true` if the keyword associated with this token is `final` or
/// `const`.
bool isFinalOrConst(Token token) =>
    isKeyword(token, Keyword.FINAL) || isKeyword(token, Keyword.CONST);

/// Returns `true` if this element is a `hashCode` method or field declaration.
bool isHashCode(ClassMember element) => _hasFieldOrMethod(element, 'hashCode');

/// Returns `true` if this element is an `index` method or field declaration.
bool isIndex(ClassMember element) => _hasFieldOrMethod(element, 'index');

/// Return true if this compilation unit [node] is declared within the given
/// [package]'s `lib/` directory tree.
bool isInLibDir(CompilationUnit node, WorkspacePackage? package) {
  if (package == null) {
    return false;
  }
  final cuPath = node.declaredElement?.library.source.fullName;
  if (cuPath == null) {
    return false;
  }
  final libDir = path.join(package.root, 'lib');

  return path.isWithin(libDir, cuPath);
}

/// Return `true` if this compilation unit [node] is declared within a public
/// directory in the given [package]'s directory tree. Public dirs are the
/// `lib` and `bin` dirs.
bool isInPublicDir(CompilationUnit node, WorkspacePackage? package) {
  if (package == null) {
    return false;
  }
  final cuPath = node.declaredElement?.library.source.fullName;
  if (cuPath == null) {
    return false;
  }
  final libDir = path.join(package.root, 'lib');
  final binDir = path.join(package.root, 'bin');

  return path.isWithin(libDir, cuPath) || path.isWithin(binDir, cuPath);
}

/// Returns `true` if the keyword associated with the given [token] matches
/// [keyword].
bool isKeyword(Token token, Keyword keyword) =>
    token is KeywordToken && token.keyword == keyword;

/// Returns `true` if the given [id] is a Dart keyword.
bool isKeyWord(String id) => Keyword.keywords.containsKey(id);

/// Returns `true` if the given [ClassMember] is a method.
bool isMethod(ClassMember m) => m is MethodDeclaration;

/// Returns `true` if the given [ClassMember] is a public method.
bool isPublicMethod(ClassMember m) {
  final declaredElement = m.declaredElement;

  return declaredElement != null && isMethod(m) && declaredElement.isPublic;
}

/// Check if the given word is a Dart reserved word.
bool isReservedWord(String word) => reservedWords.contains(word);

/// Returns `true` if the given [setter] is a "simple setter".
///
/// A simple setter takes this basic form:
///
/// ```dart
/// int _x;
/// set(int x) {
///   _x = x;
/// }
/// ```
///
/// or:
///
/// ```dart
/// int _x;
/// set(int x) => _x = x;
/// ```
///
/// where the static type of the left and right hand sides of the assignment
/// expression are the same.
bool isSimpleSetter(MethodDeclaration setter) {
  final body = setter.body;
  if (body is ExpressionFunctionBody) {
    return _checkForSimpleSetter(setter, body.expression);
  } else if (body is BlockFunctionBody) {
    final block = body.block;
    if (block.statements.length == 1) {
      final statement = block.statements.first;
      if (statement is ExpressionStatement) {
        return _checkForSimpleSetter(setter, statement.expression);
      }
    }
  }

  return false;
}

/// Returns `true` if the given [id] is a valid Dart identifier.
bool isValidDartIdentifier(String id) => !isKeyWord(id) && isIdentifier(id);

/// Returns `true` if this element is a `values` method or field declaration.
bool isValues(ClassMember element) => _hasFieldOrMethod(element, 'values');

/// Returns `true` if the keyword associated with this token is `var`.
bool isVar(Token token) => isKeyword(token, Keyword.VAR);

/// Return the nearest enclosing pubspec file.
File? locatePubspecFile(CompilationUnit compilationUnit) {
  final fullName = compilationUnit.declaredElement?.source.fullName;
  if (fullName == null) {
    return null;
  }

  final resourceProvider =
      compilationUnit.declaredElement?.session.resourceProvider;
  if (resourceProvider == null) {
    return null;
  }

  final file = resourceProvider.getFile(fullName);

  // Look for a pubspec.yaml file.
  for (final folder in file.parent.withAncestors) {
    final pubspecFile = folder.getChildAssumingFile('pubspec.yaml');
    if (pubspecFile.exists) {
      return pubspecFile;
    }
  }

  return null;
}

/// Uses [processor] to visit all of the children of [element].
/// If [processor] returns `true`, then children of a child are visited too.
void visitChildren(Element element, ElementProcessor processor) {
  element.visitChildren(_ElementVisitorAdapter(processor));
}

bool _checkForSimpleSetter(MethodDeclaration setter, Expression expression) {
  if (expression is! AssignmentExpression) {
    return false;
  }
  if (expression.operator.type != TokenType.EQ) {
    return false;
  }

  final leftHandSide = expression.leftHandSide;
  final rightHandSide = expression.rightHandSide;
  if (leftHandSide is SimpleIdentifier && rightHandSide is SimpleIdentifier) {
    final leftElement = expression.writeElement;
    if (leftElement is! PropertyAccessorElement || !leftElement.isSynthetic) {
      return false;
    }

    // To guard against setters used as type constraints
    if (expression.writeType != rightHandSide.staticType) {
      return false;
    }

    final rightElement = rightHandSide.staticElement;
    if (rightElement is! ParameterElement) {
      return false;
    }

    final parameters = setter.parameters?.parameters;
    if (parameters != null && parameters.length == 1) {
      return rightElement == parameters.first.declaredElement;
    }
  }

  return false;
}

List<String> _collectReservedWords() {
  final reserved = <String>[];
  for (final entry in Keyword.keywords.entries) {
    if (entry.value.isReservedWord) {
      reserved.add(entry.key);
    }
  }

  return reserved;
}

/// If the [node] is the target of a [CompoundAssignmentExpression],
/// return the corresponding "writeElement", which is the local variable,
/// the setter referenced with a [SimpleIdentifier] or a [PropertyAccess],
/// or the `[]=` operator.
Element? _getWriteElement(AstNode node) {
  final parent = node.parent;
  if (parent is AssignmentExpression && parent.leftHandSide == node) {
    return parent.writeElement;
  }
  if (parent is PostfixExpression) {
    return parent.writeElement;
  }
  if (parent is PrefixExpression) {
    return parent.writeElement;
  }

  if (parent is PrefixedIdentifier && parent.identifier == node) {
    return _getWriteElement(parent);
  }

  if (parent is PropertyAccess && parent.propertyName == node) {
    return _getWriteElement(parent);
  }

  return null;
}

bool _hasFieldOrMethod(ClassMember element, String name) =>
    (element is MethodDeclaration && element.name.lexeme == name) ||
    (element is FieldDeclaration && getFieldName(element, name) != null);

/// An [Element] processor function type.
/// If `true` is returned, children of [element] will be visited.
typedef ElementProcessor = bool Function(Element element);

/// A [GeneralizingElementVisitor] adapter for [ElementProcessor].
// ignore: strict_raw_type
class _ElementVisitorAdapter extends GeneralizingElementVisitor {
  final ElementProcessor processor;

  _ElementVisitorAdapter(this.processor);

  @override
  void visitElement(Element element) {
    final visitChildren = processor(element);
    if (visitChildren) {
      element.visitChildren(this);
    }
  }
}

extension AstNodeExtension on AstNode {
  bool get isToStringInvocationWithArguments {
    final self = this;

    return self is MethodInvocation &&
        self.methodName.name == 'toString' &&
        self.argumentList.arguments.isNotEmpty;
  }
}

extension ElementExtension on Element? {
  bool get isDartCorePrint {
    final self = this;

    return self is FunctionElement &&
        self.name == 'print' &&
        self.library.isDartCore;
  }
}
