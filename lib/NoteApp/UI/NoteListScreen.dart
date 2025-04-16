import 'package:flutter/material.dart';
import 'package:app_02/NoteApp/DatabaseHelper/DatabaseHelper.dart';
import 'package:app_02/NoteApp/Model/NoteModel.dart';
import 'package:app_02/NoteApp/UI/NoteForm.dart';
import 'package:app_02/NoteApp/widgets/NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;

  const NoteListScreen({super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late List<Note> notes = [];
  bool isLoading = true;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() => isLoading = true);
    notes = await NoteDatabaseHelper.instance.getAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Chú'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.onThemeChanged,
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text('Không có ghi chú nào', style: TextStyle(fontSize: 18)))
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isGridView
            ? GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteItem(
            note: notes[index],
            onDelete: _refreshNotes,
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteItem(
            note: notes[index],
            onDelete: _refreshNotes,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormScreen()),
          );
          _refreshNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}