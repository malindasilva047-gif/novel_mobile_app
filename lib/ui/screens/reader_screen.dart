import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
    required this.title,
    required this.author,
    required this.description,
  });

  final String title;
  final String author;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'serif',
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'by $author',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Text(
              description.isEmpty
                  ? 'This story is ready in your reader. Full chapter content can be edited from the Write tab.'
                  : description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Reader preview mode. Replace this with full chapter rendering later.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}