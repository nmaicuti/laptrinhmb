import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../DatabaseHelper/DatabaseHelper.dart';
import '../Model/NoteModel.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;
  const NoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  int priority = 1;
  Color selectedColor = Colors.white;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    priority = widget.note?.priority ?? 1;
    selectedColor = widget.note != null ? Color(int.parse('0xff${widget.note!.color}')) : Colors.white;
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.note?.imagePath != null && File(widget.note!.imagePath!).existsSync()) {
      setState(() => _imageFile = File(widget.note!.imagePath!));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/note_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newImage = await File(image.path).copy(newPath);
      setState(() => _imageFile = newImage);
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        priority: priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        color: selectedColor.value.toRadixString(16).substring(2),
        imagePath: _imageFile?.path,
      );
      widget.note == null
          ? await NoteDatabaseHelper.instance.insertNote(note)
          : await NoteDatabaseHelper.instance.updateNote(note);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Thêm Ghi Chú' : 'Sửa Ghi Chú')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: content,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
                onSaved: (value) => content = value!,
              ),
              DropdownButtonFormField<int>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) => setState(() => priority = value!),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text(widget.note == null ? 'Lưu' : 'Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
