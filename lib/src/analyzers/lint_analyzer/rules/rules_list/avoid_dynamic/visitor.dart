part of 'avoid_dynamic_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitNamedType(NamedType node) {
    if (node.type is DynamicType) {
      final parent = node.parent;
      if (parent != null && !_isWithinMap(parent)) {
        _nodes.add(parent);
      }
    }
    super.visitNamedType(node);
  }

  bool _isWithinMap(AstNode parent) {
    final grandParent = parent.parent;

    return grandParent is NamedType &&
            (grandParent.type?.isDartCoreMap ?? false) ||
        grandParent is SetOrMapLiteral && grandParent.isMap;
  }
}
