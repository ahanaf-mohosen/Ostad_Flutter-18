import 'package:firebase_task_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TaskManagerApp smoke test - renders initial loading UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskManagerApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
