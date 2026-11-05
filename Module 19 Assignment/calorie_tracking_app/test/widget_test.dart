import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_tracking_app/main.dart';

void main() {
  testWidgets('validates food input and updates totals when adding and deleting', (tester) async {
    await tester.pumpWidget(const CalorieTrackerApp());

    expect(find.text('Calorie Tracker'), findsOneWidget);
    expect(find.text('2000'), findsNWidgets(2));
    expect(find.text('Nothing on your plate yet'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Add food');
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text('Enter a food name'), findsOneWidget);
    expect(find.text('Enter a number greater than 0'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Oatmeal');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text('Enter a number greater than 0'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), '12.5');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Oatmeal'), findsOneWidget);
    expect(find.text('12.5 kcal'), findsOneWidget);
    expect(find.text('1987.5 kcal left'), findsOneWidget);
    expect(find.text('1987.5'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Oatmeal'));
    await tester.pumpAndSettle();

    expect(find.text('Oatmeal'), findsNothing);
    expect(find.text('Nothing on your plate yet'), findsOneWidget);
    expect(find.text('2000 kcal left'), findsOneWidget);
  });
}
