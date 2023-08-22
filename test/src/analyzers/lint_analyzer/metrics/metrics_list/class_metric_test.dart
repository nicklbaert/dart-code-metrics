// TODO(JonasWanke): Re-add when mocking a final class works
// class CompilationUnitMemberMock extends Mock implements CompilationUnitMember {}

// class DocumentationMock extends Mock implements MetricDocumentation {}

// class ClassMetricTest extends ClassMetric<int> {
//   ClassMetricTest()
//       : super(
//           id: '0',
//           documentation: DocumentationMock(),
//           threshold: 0,
//           levelComputer: (_, __) => MetricValueLevel.none,
//         );

//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }

// void main() {
//   test('ClassMetric nodeType returns type of passed node', () {
//     final firstNode = CompilationUnitMemberMock();
//     final secondNode = CompilationUnitMemberMock();
//     final thirdNode = CompilationUnitMemberMock();
//     final fourthNode = CompilationUnitMemberMock();

//     final classes = [
//       ScopedClassDeclaration(ClassType.generic, firstNode),
//       ScopedClassDeclaration(ClassType.mixin, secondNode),
//       ScopedClassDeclaration(ClassType.extension, thirdNode),
//     ];

//     expect(ClassMetricTest().nodeType(firstNode, classes, []), equals('class'));
//     expect(
//       ClassMetricTest().nodeType(secondNode, classes, []),
//       equals('mixin'),
//     );
//     expect(
//       ClassMetricTest().nodeType(thirdNode, classes, []),
//       equals('extension'),
//     );
//     expect(ClassMetricTest().nodeType(fourthNode, classes, []), isNull);
//   });
// }

// ignore: no-empty-block
void main() {}
