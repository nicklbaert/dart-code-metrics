// TODO(JonasWanke): Re-add when mocking a final class works
// const _examplePath = 'long_method/examples/example.dart';
// const _widgetExamplePath = 'long_method/examples/widget.dart';

// void main() {
//   group('LongMethod', () {
//     test('report about found design issues', () async {
//       final unit = await AntiPatternTestHelper.resolveFromFile(_examplePath);

//       final scopeVisitor = ScopeVisitor();
//       unit.unit.visitChildren(scopeVisitor);

//       final declarations = scopeVisitor.functions.where((function) {
//         final declaration = function.declaration;
//         if (declaration is ConstructorDeclaration &&
//             declaration.body is EmptyFunctionBody) {
//           return false;
//         } else if (declaration is MethodDeclaration &&
//             declaration.body is EmptyFunctionBody) {
//           return false;
//         }

//         return true;
//       });

//       final issues = LongMethod(
//         metricsThresholds: {SourceLinesOfCodeMetric.metricId: 25},
//       ).check(unit, {}, {
//         declarations.first: Report(
//           location:
//               nodeLocation(node: declarations.first.declaration, source: unit),
//           metrics: [
//             buildMetricValueStub(
//               id: SourceLinesOfCodeMetric.metricId,
//               value: 55,
//               level: MetricValueLevel.warning,
//             ),
//           ],
//           declaration: declarations.first.declaration,
//         ),
//       });

//       AntiPatternTestHelper.verifyInitialization(
//         issues: issues,
//         antiPatternId: 'long-method',
//         severity: Severity.warning,
//       );

//       AntiPatternTestHelper.verifyIssues(
//         issues: issues,
//         startOffsets: [0],
//         startLines: [1],
//         startColumns: [1],
//         endOffsets: [1309],
//         messages: [
//           'Long function. This function contains 55 lines with code.',
//         ],
//         verboseMessage: [
//           "Based on configuration of this package, we don't recommend write a function longer than 25 lines with code.",
//         ],
//       );
//     });

//     test('skip widget build method', () async {
//       final unit =
//           await AntiPatternTestHelper.resolveFromFile(_widgetExamplePath);

//       final scopeVisitor = ScopeVisitor();
//       unit.unit.visitChildren(scopeVisitor);

//       final declarations = scopeVisitor.functions.where((function) {
//         final declaration = function.declaration;
//         if (declaration is ConstructorDeclaration &&
//             declaration.body is EmptyFunctionBody) {
//           return false;
//         } else if (declaration is MethodDeclaration &&
//             declaration.body is EmptyFunctionBody) {
//           return false;
//         }

//         return true;
//       });

//       final issues = LongMethod(
//         metricsThresholds: {SourceLinesOfCodeMetric.metricId: 25},
//       ).check(unit, {}, {
//         declarations.first: Report(
//           location:
//               nodeLocation(node: declarations.first.declaration, source: unit),
//           metrics: [
//             buildMetricValueStub(
//               id: SourceLinesOfCodeMetric.metricId,
//               value: 55,
//               level: MetricValueLevel.warning,
//             ),
//           ],
//           declaration: declarations.first.declaration,
//         ),
//       });

//       expect(issues, isEmpty);

//       final fallbackIssues = LongMethod().check(unit, {}, {
//         declarations.first: Report(
//           location:
//               nodeLocation(node: declarations.first.declaration, source: unit),
//           metrics: [
//             buildMetricValueStub(
//               id: SourceLinesOfCodeMetric.metricId,
//               value: 55,
//             ),
//           ],
//           declaration: declarations.first.declaration,
//         ),
//       });

//       expect(fallbackIssues, isEmpty);
//     });
//   });
// }

// ignore: no-empty-block
void main() {}
