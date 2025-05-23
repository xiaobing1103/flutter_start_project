import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class AnimatedCard extends StatelessWidget {
  final WordPair pair;
  const AnimatedCard({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: theme.colorScheme.primaryContainer,
        child: ListTile(
          leading: Icon(
            Icons.favorite,
            color: theme.colorScheme.secondary,
          ),
          title: Text(
            pair.asPascalCase,
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '这是一个收藏的单词',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
