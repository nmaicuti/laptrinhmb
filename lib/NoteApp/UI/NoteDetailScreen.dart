import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/NoteApp/Model/NoteModel.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.description, color: Colors.deepPurple),
                        title: Text(note.content, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.flag, color: Colors.orange),
                        title: Text(
                          'Ưu tiên: ${note.priority == 1 ? "Thấp" : note.priority == 2 ? "Trung bình" : "Cao"}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time, color: Colors.green),
                        title: Text('Tạo: ${note.createdAt}', style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      ListTile(
                        leading: const Icon(Icons.update, color: Colors.blue),
                        title: Text('Sửa: ${note.modifiedAt}', style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      if (note.tags != null && note.tags!.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.label, color: Colors.teal),
                          title: Text('Nhãn: ${note.tags!.join(', ')}', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      if (note.color != null)
                        ListTile(
                          leading: const Icon(Icons.color_lens, color: Colors.pink),
                          title: Text('Màu: ${note.color}', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (note.imagePath != null && note.imagePath!.isNotEmpty)
                FutureBuilder<bool>(
                  future: Future(() async {
                    try {
                      final file = File(note.imagePath!);
                      return await file.exists();
                    } catch (e) {
                      return false;
                    }
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data == true) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ảnh đính kèm:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(note.imagePath!),
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('Không thể tải ảnh');
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}