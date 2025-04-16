import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_02/NoteApp/DatabaseHelper/DatabaseHelper.dart';
import "package:app_02/NoteApp/Model/NoteModel.dart";
import "package:app_02/NoteApp/UI/NoteDetailScreen.dart";
import "package:app_02/NoteApp/UI/NoteForm.dart";
import "package:app_02/NoteApp/widgets/NoteItem.dart";
import "package:app_02/NoteApp/UI/NoteListScreen.dart";
import 'package:image_picker/image_picker.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;

  const NoteItem({super.key, required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color priorityColor = note.priority == 1
        ? Colors.green
        : note.priority == 2
        ? Colors.orange
        : Colors.red;

    return Card(
      child: Column(
        children: [
          // Phần tiêu đề với màu nền và biểu tượng thư mục
          Container(
            color: note.color != null ? Color(int.parse('0xff${note.color}')) : Theme.of(context).cardTheme.color,
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần nội dung và ảnh (nếu có)
          ListTile(
            leading: note.imagePath != null && File(note.imagePath!).existsSync()
                ? Image.file(
              File(note.imagePath!),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : null,
            subtitle: Text(
              note.content.length > 20 ? '${note.content.substring(0, 20)}...' : note.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteFormScreen(note: note),
                      ),
                    );
                    onDelete();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: const Text('Bạn có chắc muốn xóa ghi chú này không?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await NoteDatabaseHelper.instance.deleteNote(note.id!);
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}