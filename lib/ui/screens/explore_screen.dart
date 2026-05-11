import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/app_bootstrap.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key, required this.topics});

  final List<ExploreTopicModel> topics;

  static const Map<String, List<ExploreTopicModel>> _subtopicsByGenre = {
    'Fanfiction': [
      ExploreTopicModel(name: '# Kookmin', topicCount: 0),
      ExploreTopicModel(name: '# Bts Army', topicCount: 0),
      ExploreTopicModel(name: '# Bts Jimin', topicCount: 0),
      ExploreTopicModel(name: '# Exo', topicCount: 0),
      ExploreTopicModel(name: '# Bts Taehyung', topicCount: 0),
      ExploreTopicModel(name: '# My Hero Academia', topicCount: 0),
      ExploreTopicModel(name: '# Jungkook', topicCount: 0),
      ExploreTopicModel(name: '# Army', topicCount: 0),
      ExploreTopicModel(name: '# Jikook', topicCount: 0),
      ExploreTopicModel(name: '# Jimin', topicCount: 0),
      ExploreTopicModel(name: '# Kpop', topicCount: 0),
      ExploreTopicModel(name: '# Taekook', topicCount: 0),
      ExploreTopicModel(name: '# Supernatural', topicCount: 0),
      ExploreTopicModel(name: '# Marvel', topicCount: 0),
      ExploreTopicModel(name: '# Btsfanfiction', topicCount: 0),
      ExploreTopicModel(name: '# Straykids', topicCount: 0),
      ExploreTopicModel(name: '# Harrypotter', topicCount: 0),
      ExploreTopicModel(name: '# Twilight', topicCount: 0),
    ],
    'Fantasy': [
      ExploreTopicModel(name: 'All Fantasy', topicCount: 0),
      ExploreTopicModel(name: '# Demons', topicCount: 0),
      ExploreTopicModel(name: '# Fantasy Adventure', topicCount: 0),
      ExploreTopicModel(name: '# Fantasy Short Story', topicCount: 0),
      ExploreTopicModel(name: '# Fantasy Romance', topicCount: 0),
      ExploreTopicModel(name: '# Knights', topicCount: 0),
      ExploreTopicModel(name: '# Fantasy Humor', topicCount: 0),
      ExploreTopicModel(name: '# Magic', topicCount: 0),
      ExploreTopicModel(name: '# Science Fantasy', topicCount: 0),
      ExploreTopicModel(name: '# War', topicCount: 0),
      ExploreTopicModel(name: '# Vampire', topicCount: 0),
    ],
  };

  static const List<ExploreTopicModel> _fallbackTopics = [
    ExploreTopicModel(name: 'Fanfiction', topicCount: 100),
    ExploreTopicModel(name: 'Fantasy', topicCount: 31),
    ExploreTopicModel(name: 'Poetry', topicCount: 14),
    ExploreTopicModel(name: 'Adventure', topicCount: 35),
    ExploreTopicModel(name: 'Horror', topicCount: 29),
    ExploreTopicModel(name: 'Thriller', topicCount: 35),
    ExploreTopicModel(name: 'Young Adult', topicCount: 6),
    ExploreTopicModel(name: 'LGBTQ+', topicCount: 0),
    ExploreTopicModel(name: 'Literary Fiction', topicCount: 0),
    ExploreTopicModel(name: 'Historical Fiction', topicCount: 0),
    ExploreTopicModel(name: 'Erotica', topicCount: 32),
    ExploreTopicModel(name: 'Mystery', topicCount: 32),
    ExploreTopicModel(name: 'SciFi', topicCount: 31),
    ExploreTopicModel(name: 'Humor', topicCount: 24),
    ExploreTopicModel(name: 'Action', topicCount: 33),
    ExploreTopicModel(name: 'Drama', topicCount: 30),
    ExploreTopicModel(name: 'Romance', topicCount: 35),
  ];

  @override
  Widget build(BuildContext context) {
    final displayTopics = topics.isNotEmpty ? topics : _fallbackTopics;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Explore',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: displayTopics.length,
        separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
        itemBuilder: (context, index) {
          final topic = displayTopics[index];
          return _GenreListTile(topic: topic);
        },
      ),
    );
  }
}

class _GenreListTile extends StatelessWidget {
  const _GenreListTile({required this.topic});

  final ExploreTopicModel topic;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final subtopics = ExploreScreen._subtopicsByGenre[topic.name];
        if (subtopics != null && subtopics.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => _ExploreSubtopicsScreen(
                title: topic.name == 'Fanfiction' ? 'Fanfictions' : topic.name,
                topics: subtopics,
              ),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => _GenreStoriesScreen(genre: topic.name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                topic.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.ink,
                ),
              ),
            ),
            Text(
              topic.topicCount > 0 ? '${topic.topicCount} topics' : '0 topics',
              style: const TextStyle(fontSize: 14, color: AppTheme.muted),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _GenreStoriesScreen extends StatelessWidget {
  const _GenreStoriesScreen({required this.genre});

  final String genre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(genre),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 64, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(
              'Stories in $genre',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreSubtopicsScreen extends StatelessWidget {
  const _ExploreSubtopicsScreen({required this.title, required this.topics});

  final String title;
  final List<ExploreTopicModel> topics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: topics.length,
        separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            title: Text(topic.name),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.muted,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _GenreStoriesScreen(genre: topic.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
