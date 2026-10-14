import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/new_post_dialog.dart';
import '../widgets/post_tile.dart';
import '../widgets/state_views.dart';

/// Route '/' - lists all posts fetched from the REST API.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  Box get _box => Hive.box(favoritesBoxName);

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // Part 2: async method called from initState()
  }

  // ---------------------------------------------------------------- GET
  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse(postsUrl))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _posts = data.map((e) => Post.fromMap(e as Map)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'The server responded with status ${response.statusCode}.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load posts. Check your internet connection and try again.';
        _loading = false;
      });
    }
  }

  // --------------------------------------------------------------- POST
  Future<void> _openNewPostDialog() async {
    final result = await showDialog<({String title, String body})>(
      context: context,
      builder: (_) => const NewPostDialog(),
    );
    if (result == null) return;
    await _createPost(result.title, result.body);
  }

  Future<void> _createPost(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(postsUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final created = jsonDecode(response.body) as Map<String, dynamic>;
        var id = (created['id'] ?? 101) as int;
        // JSONPlaceholder always answers with id 101 - keep local ids unique.
        if (_posts.any((p) => p.id == id)) {
          id = _posts.map((p) => p.id).reduce(math.max) + 1;
        }
        setState(() {
          _posts.insert(0, Post(id: id, userId: 1, title: title, body: body));
        });
        _showResult('Post created successfully (201).', success: true);
      } else {
        _showResult('Failed to create post (status ${response.statusCode}).',
            success: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showResult('Failed to create post. Please check your connection.',
          success: false);
    }
  }

  void _showResult(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? AppTheme.forest : const Color(0xFFB3261E),
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  // ----------------------------------------------------------------- UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Post Reader '),
              TextSpan(
                text: '&',
                style: TextStyle(color: AppTheme.coral),
              ),
              const TextSpan(text: ' Favorites'),
            ],
          ),
        ),
        actions: [
          // Favorites button with a live badge of saved posts.
          ValueListenableBuilder<Box>(
            valueListenable: _box.listenable(),
            builder: (context, box, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Favorites',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.favorites),
                icon: Badge(
                  isLabelVisible: box.isNotEmpty,
                  label: Text('${box.length}'),
                  backgroundColor: AppTheme.coral,
                  child: const Icon(Icons.favorite_rounded, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewPostDialog,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New post',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.forest),
      );
    }
    if (_error != null) {
      return MessageView(
        icon: Icons.wifi_off_rounded,
        color: AppTheme.coral,
        title: 'Something went wrong',
        message: _error!,
        actionLabel: 'Try again',
        onAction: _fetchPosts,
      );
    }

    return RefreshIndicator(
      color: AppTheme.forest,
      onRefresh: _fetchPosts,
      child: ValueListenableBuilder<Box>(
        valueListenable: _box.listenable(),
        builder: (context, box, _) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: _posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _Header(total: _posts.length, saved: box.length);

              final post = _posts[index - 1];
              return PostTile(
                post: post,
                isSaved: box.containsKey(post.id),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.details,
                  arguments: post, // passed to the details route
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  final int saved;
  const _Header({required this.total, required this.saved});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your reading list',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap a post to read it, then save it to your favorites.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _Stat(value: '$total', label: 'posts'),
          const SizedBox(width: 10),
          _Stat(value: '$saved', label: 'saved', highlight: true),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;
  const _Stat({required this.value, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.coral : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85), fontSize: 11)),
        ],
      ),
    );
  }
}
