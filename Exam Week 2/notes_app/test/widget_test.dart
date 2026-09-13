import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/home_screen.dart';

void main() {
  late Directory testDirectory;
  late Box<Note> notesBox;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp(
      'notes_app_test',
    );

    Hive.init(testDirectory.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }

    notesBox = await Hive.openBox<Note>('notes');
  });

  setUp(() async {
    await notesBox.clear();
  });

  tearDownAll(() async {
    await notesBox.close();
    await testDirectory.delete(recursive: true);
  });

  Widget createTestApp() {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }

  testWidgets('Home screen displays empty state', (tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Create your first note to get started.'), findsOneWidget);
  });

  testWidgets('User can add a new note', (tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();

    expect(find.text('Add Note'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Flutter Test Note',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'This note was created during automated testing.',
    );

    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Test Note'), findsOneWidget);

    expect(notesBox.length, 1);
    expect(notesBox.values.first.title, 'Flutter Test Note');
    expect(
      notesBox.values.first.description,
      'This note was created during automated testing.',
    );
  });

  testWidgets('User can search notes by title', (tester) async {
    await notesBox.add(
      Note(
        title: 'Flutter Project',
        description: 'Flutter description',
        createdAt: DateTime.now(),
      ),
    );

    await notesBox.add(
      Note(
        title: 'Database Project',
        description: 'Database description',
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Project'), findsOneWidget);
    expect(find.text('Database Project'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Flutter',
    );

    await tester.pump();

    expect(find.text('Flutter Project'), findsOneWidget);
    expect(find.text('Database Project'), findsNothing);
  });

  testWidgets('User can edit an existing note', (tester) async {
    final note = Note(
      title: 'Old Title',
      description: 'Old Description',
      createdAt: DateTime.now(),
    );

    await notesBox.add(note);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Old Title'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Updated Title',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Updated Description',
    );

    await tester.tap(find.text('Update Note'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Title'), findsOneWidget);

    expect(notesBox.values.first.title, 'Updated Title');
    expect(
      notesBox.values.first.description,
      'Updated Description',
    );
  });

  testWidgets('User can delete a note', (tester) async {
    final note = Note(
      title: 'Note To Delete',
      description: 'This note will be deleted.',
      createdAt: DateTime.now(),
    );

    await notesBox.add(note);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Note To Delete'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Note'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Delete'),
    );

    await tester.pumpAndSettle();

    expect(find.text('Note To Delete'), findsNothing);
    expect(notesBox.isEmpty, true);
  });

  testWidgets('User can open note details', (tester) async {
    await notesBox.add(
      Note(
        title: 'My Details Note',
        description: 'This is the full note description.',
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Details Note'));
    await tester.pumpAndSettle();

    expect(find.text('Note Details'), findsOneWidget);
    expect(find.text('My Details Note'), findsOneWidget);
    expect(
      find.text('This is the full note description.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('Title validation works', (tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Description without title',
    );

    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a title'),
      findsOneWidget,
    );

    expect(notesBox.isEmpty, true);
  });

  testWidgets('Description validation works', (tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Test Title',
    );

    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a description'),
      findsOneWidget,
    );

    expect(notesBox.isEmpty, true);
  });
}