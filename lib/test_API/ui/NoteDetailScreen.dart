import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:app_02/noteApp/model/NoteModel.dart";

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không rõ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title, style: textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nội dung', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(note.content, style: textTheme.bodyLarge),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 20),
                      const SizedBox(width: 8),
                      Text('Ưu tiên: ${getPriorityText(note.priority)}', style: textTheme.bodyLarge),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text('Tạo: ${_formatDate(note.createdAt)}', style: textTheme.bodyLarge),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.update, size: 20),
                      const SizedBox(width: 8),
                      Text('Sửa: ${_formatDate(note.modifiedAt)}', style: textTheme.bodyLarge),
                    ],
                  ),

                  if (note.tags != null && note.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Nhãn', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: note.tags!
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],

                  if (note.color != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Màu: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(int.parse(note.color!)),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        )
                      ],
                    ),
                  ],

                  if (note.imagePath != null && note.imagePath!.isNotEmpty)
                    FutureBuilder<bool>(
                      future: Future(() async {
                        try {
                          final file = File(note.imagePath!);
                          return await file.exists();
                        } catch (_) {
                          return false;
                        }
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasData && snapshot.data == true) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text('Ảnh đính kèm', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(note.imagePath!),
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Text('Không thể tải ảnh'),
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
        ),
      ),
    );
  }
}
