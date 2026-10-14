import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/note_dialog.dart';
import '../widgets/state_views.dart';

/// Route '/favorites' - Read / Update / Delete saved posts (Hive).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(favoritesBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          // READ: all saved posts via box.values
          final items = box.values
              .map((v) => Map<String, dynamic>.from(v as Map))
              .toList();

          if (items.isEmpty) {
            return const MessageView(
              icon: Icons.favorite_border_rounded,
              title: 'No favorites yet',
              message:
                  'Open a post and tap "Save to Favorites" to keep it here, even after you close the app.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index];
              return _FavoriteCard(
                data: data,
                onEditNote: () => _editNote(context, box, data),
                onDelete: () => _delete(context, box, data),
              );
            },
          );
        },
      ),
    );
  }

  // UPDATE: edit the personal note and write the change back to the box.
  Future<void> _editNote(
      BuildContext context, Box box, Map<String, dynamic> data) async {
    final newNote = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(initialNote: (data['note'] ?? '') as String),
    );
    if (newNote == null) return;
    await box.put(data['id'], {...data, 'note': newNote});
  }

  // DELETE: remove with box.delete(key), with an undo option.
  Future<void> _delete(
      BuildContext context, Box box, Map<String, dynamic> data) async {
    await box.delete(data['id']);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Removed from favorites.'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppTheme.coral,
            onPressed: () => box.put(data['id'], data),
          ),
        ),
      );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEditNote;
  final VoidCallback onDelete;

  const _FavoriteCard({
    required this.data,
    required this.onEditNote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final post = Post.fromMap(data);
    final note = (data['note'] ?? '') as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(post.id),
        direction: DismissDirection.endToStart, // swipe to delete
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppTheme.coral,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.sand),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.forest.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('#${post.id}',
                        style: const TextStyle(
                            color: AppTheme.forest,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                  ),
                  const Spacer(),
                  _RoundIconButton(
                    icon: Icons.edit_note_rounded,
                    tooltip: 'Edit note',
                    onTap: onEditNote,
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: AppTheme.coral,
                    onTap: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(post.prettyTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(post.prettyBody,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onEditNote,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sticky_note_2_outlined,
                          size: 18, color: AppTheme.coral),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          note.isEmpty ? 'Add a personal note…' : note,
                          style: TextStyle(
                            color:
                                note.isEmpty ? AppTheme.muted : AppTheme.ink,
                            fontStyle:
                                note.isEmpty ? FontStyle.italic : FontStyle.normal,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppTheme.forest,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
