import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';

/// Route '/details' - receives the selected Post via route arguments.
class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the argument passed by Navigator.pushNamed(...)
    final post = ModalRoute.of(context)!.settings.arguments as Post;
    final box = Hive.box(favoritesBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context), // go back
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              _Chip(label: 'POST #${post.id}', color: AppTheme.forest),
              const SizedBox(width: 8),
              _Chip(label: 'AUTHOR ${post.userId}', color: AppTheme.coral),
            ],
          ),
          const SizedBox(height: 18),
          Text(post.prettyTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Container(
            height: 4,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.coral,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.sand),
            ),
            child: Text(post.prettyBody,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ValueListenableBuilder<Box>(
            valueListenable: box.listenable(),
            builder: (context, box, _) {
              final saved = box.containsKey(post.id);
              return FilledButton.icon(
                onPressed: saved ? null : () => _save(context, box, post),
                icon: Icon(saved
                    ? Icons.check_rounded
                    : Icons.favorite_border_rounded),
                label: Text(saved ? 'Saved to favorites' : 'Save to Favorites'),
              );
            },
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context, Box box, Post post) {
    // Prevent duplicates: the post id is the key.
    if (box.containsKey(post.id)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Already in favorites.')));
      return;
    }
    box.put(post.id, {...post.toMap(), 'note': ''}); // saved as a Map
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Saved to favorites.'),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: AppTheme.coral,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.favorites),
          ),
        ),
      );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
            letterSpacing: 0.8,
          )),
    );
  }
}
