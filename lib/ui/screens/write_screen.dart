import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/app_bootstrap.dart';
import '../../data/services/api_service.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key, required this.data, required this.apiService});

  final AppBootstrap data;
  final ApiService apiService;

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen>
    with TickerProviderStateMixin {
  late TabController _topTabs;
  late TabController _storyTabs;
  late Future<List<Map<String, dynamic>>> _storiesFuture;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _topTabs = TabController(
      length: widget.data.writeScreen.manageTabs.length,
      vsync: this,
    );
    _storyTabs = TabController(
      length: widget.data.writeScreen.storyTabs.length,
      vsync: this,
    );
    _storiesFuture = widget.apiService.fetchWriterStories();
  }

  @override
  void dispose() {
    _topTabs.dispose();
    _storyTabs.dispose();
    super.dispose();
  }

  Future<void> _reloadStories() async {
    setState(() {
      _storiesFuture = widget.apiService.fetchWriterStories();
    });
    await _storiesFuture;
  }

  Future<void> _openCreateOrEditDialog({Map<String, dynamic>? story}) async {
    final titleController = TextEditingController(
      text: story?['title']?.toString() ?? '',
    );
    final authorController = TextEditingController(
      text: story?['author']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: story?['description']?.toString() ?? '',
    );
    final genreController = TextEditingController(
      text: story?['genre']?.toString() ?? 'Romance',
    );

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(story == null ? 'Create Story' : 'Edit Story'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                TextField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: 'Genre'),
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Summary'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (submitted != true) return;

    final payload = {
      'title': titleController.text.trim(),
      'author': authorController.text.trim(),
      'genre': genreController.text.trim(),
      'description': descriptionController.text.trim(),
    };

    if (payload.values.any((v) => v.isEmpty)) return;

    if (story == null) {
      await widget.apiService.createWriterStory(payload);
    } else {
      await widget.apiService.updateWriterStory(story['id'] as int, payload);
    }

    if (mounted) {
      await _reloadStories();
    }
  }

  Future<void> _deleteStory(int id) async {
    await widget.apiService.deleteWriterStory(id);
    if (mounted) {
      await _reloadStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeModel = widget.data.writeScreen;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Write',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _openCreateOrEditDialog(),
                icon: const Icon(Icons.add_rounded),
                iconSize: 28,
              ),
            ],
          ),
          TabBar(
            controller: _topTabs,
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.muted,
            indicatorColor: AppTheme.brand,
            tabs: writeModel.manageTabs.map((e) => Tab(text: e)).toList(),
          ),
          const SizedBox(height: 6),
          TabBar(
            controller: _storyTabs,
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.muted,
            indicatorColor: AppTheme.brand,
            tabs: writeModel.storyTabs.map((e) => Tab(text: e)).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: AppTheme.muted,
              ),
              const SizedBox(width: 4),
              Text(
                writeModel.filterLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.south_rounded, size: 18, color: AppTheme.muted),
              const SizedBox(width: 4),
              Text(
                writeModel.sortLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reloadStories,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _storiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final stories = (snapshot.data ?? <Map<String, dynamic>>[])
                      .where((story) {
                        if (_query.isEmpty) return true;
                        final title =
                            story['title']?.toString().toLowerCase() ?? '';
                        final author =
                            story['author']?.toString().toLowerCase() ?? '';
                        return title.contains(_query) ||
                            author.contains(_query);
                      })
                      .toList();

                  if (stories.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 140),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                writeModel.emptyTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                writeModel.emptyCta,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.brand),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: stories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: ListTile(
                          title: Text(story['title']?.toString() ?? ''),
                          subtitle: Text(story['author']?.toString() ?? ''),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _openCreateOrEditDialog(story: story);
                              } else if (value == 'delete') {
                                _deleteStory(story['id'] as int);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
