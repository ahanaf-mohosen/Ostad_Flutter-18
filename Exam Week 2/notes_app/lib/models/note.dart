import 'package:hive/hive.dart';

class Note extends HiveObject {
  String title;
  String description;
  DateTime createdAt;

  Note({
    required this.title,
    required this.description,
    required this.createdAt,
  });
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final title = reader.readString();
    final description = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      reader.readInt(),
    );

    return Note(
      title: title,
      description: description,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}