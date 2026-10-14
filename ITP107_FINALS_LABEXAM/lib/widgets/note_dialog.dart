import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dialog to edit a short personal note. Pops with the new note text.
class NoteDialog extends StatefulWidget {
  final String initialNote;
  const NoteDialog({super.key, required this.initialNote});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Personal note',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        maxLength: 140,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Why did you save this post?',
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          style: FilledButton.styleFrom(minimumSize: const Size(110, 46)),
          child: const Text('Save note'),
        ),
      ],
    );
  }
}
