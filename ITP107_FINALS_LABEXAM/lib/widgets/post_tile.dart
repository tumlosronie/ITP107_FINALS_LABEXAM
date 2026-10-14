import 'package:flutter/material.dart';

import '../models/post.dart';
import '../theme/app_theme.dart';

/// A single card-style row built around a ListTile.
class PostTile extends StatelessWidget {
  final Post post;
  final bool isSaved;
  final VoidCallback onTap;

  const PostTile({
    super.key,
    required this.post,
    required this.isSaved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.sand),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.forest.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${post.id}',
              style: const TextStyle(
                color: AppTheme.forest,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          title: Text(
            post.prettyTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              post.prettyBody.replaceAll('\n', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          trailing: Icon(
            isSaved ? Icons.favorite_rounded : Icons.chevron_right_rounded,
            color: isSaved ? AppTheme.coral : AppTheme.muted,
          ),
        ),
      ),
    );
  }
}
