import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({
    super.key,
    this.note,
  });

  bool get isEditing => note != null;

  @override
  State<AddEditNoteScreen> createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.note?.description ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (widget.isEditing) {
      widget.note!
        ..title = title
        ..description = description;

      await widget.note!.save();
    } else {
      final box = Hive.box<Note>('notes');

      await box.add(
        Note(
          title: title,
          description: description,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Note updated successfully'
              : 'Note added successfully',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Note' : 'Add Note',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 8,
              maxLines: 12,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Write your note...',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 150),
                  child: Icon(Icons.description_outlined),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: saveNote,
                icon: Icon(
                  widget.isEditing
                      ? Icons.save_outlined
                      : Icons.add,
                ),
                label: Text(
                  widget.isEditing ? 'Update Note' : 'Save Note',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}