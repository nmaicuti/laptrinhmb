import 'package:flutter/material.dart';
import 'package:app_02/noteApp/db/NoteDatabaseHelper.dart';
import 'package:app_02/noteApp/model/NoteModel.dart';
import 'package:app_02/noteApp/ui/NoteForm.dart';
import 'package:app_02/noteApp/ui/NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;
  final Function(BuildContext) onLogout;

  const NoteListScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _notesFuture = NoteDatabaseHelper.instance.getAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ghi chú của bạn', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 2,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeChanged,
            tooltip: widget.isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                key: ValueKey<bool>(isGridView),
              ),
            ),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _showLogoutDialog();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có ghi chú nào.'));
          }

          final notes = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshNotes,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isGridView
                  ? GridView.builder(
                key: const ValueKey('grid'),
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) => NoteItem(
                  note: notes[index],
                  onDelete: _refreshNotes,
                ),
              )
                  : ListView.builder(
                key: const ValueKey('list'),
                padding: const EdgeInsets.all(12),
                itemCount: notes.length,
                itemBuilder: (context, index) => NoteItem(
                  note: notes[index],
                  onDelete: _refreshNotes,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteFormScreen()),
          );
          if (created == true) _refreshNotes();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo ghi chú'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onLogout(context);
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
