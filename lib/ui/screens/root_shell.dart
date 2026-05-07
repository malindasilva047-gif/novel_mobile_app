import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/app_bootstrap.dart';
import '../../data/services/api_service.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final ApiService _apiService = const ApiService();
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrap>(
      future: _apiService.fetchBootstrap(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load the app data. Start the FastAPI backend or check the API URL.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final bootstrap = snapshot.data!;
        final pages = <Widget>[
          LibraryScreen(data: bootstrap),
          DiscoverScreen(data: bootstrap),
          WriteScreen(data: bootstrap),
          NotificationsScreen(data: bootstrap),
          MoreScreen(data: bootstrap),
        ];

        return Scaffold(
          body: SafeArea(child: pages[_selectedIndex]),
          bottomNavigationBar: NavigationBar(
            height: 76,
            backgroundColor: Colors.white,
            indicatorColor: Colors.transparent,
            shadowColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.edit_outlined),
                selectedIcon: Icon(Icons.edit),
                label: 'Write',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_rounded),
                selectedIcon: Icon(Icons.menu),
                label: 'More',
              ),
            ],
          ),
        );
      },
    );
  }
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key, required this.data});

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ExploreScreen(topics: data.exploreTopics),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_open_rounded, size: 30),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Inkitt',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 30, fontFamily: 'serif'),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded, size: 33),
                ),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarHeader(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 6),
              child: _CategoryTabs(labels: data.discoverTabs),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionTitle(title: 'Recently Updated'),
              const SizedBox(height: 14),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      _BookCoverCard(book: data.recentlyUpdated[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 18),
                  itemCount: data.recentlyUpdated.length,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                data.featuredBook.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.featuredBook.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF4E4E4E),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppTheme.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.featuredBook.statusText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  ...List.generate(
                    data.featuredBook.rating.round(),
                    (_) => const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF3C623),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Chip(label: Text(data.featuredBook.genre)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(data.featuredBook.cta),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              _SectionTitle(title: 'Recently Completed'),
              const SizedBox(height: 14),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      _BookCoverCard(book: data.recentlyCompleted[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 18),
                  itemCount: data.recentlyCompleted.length,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key, required this.topics});

  final List<ExploreTopicModel> topics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Explore',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                  ),
                  const Spacer(),
                  _RoundIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: topics.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      topic.name,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 17),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${topic.topicCount} topics',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.muted,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.data});

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Text(
              'Library',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 22),
            ),
          ),
          const TabBar(
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.muted,
            indicatorColor: AppTheme.brand,
            tabs: [
              Tab(text: 'Current Reads'),
              Tab(text: 'Reading Lists'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
              children: [
                Text(
                  'My Books',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                ...data.libraryEntries.map(
                  (entry) => _LibraryEntryTile(entry: entry),
                ),
                const SizedBox(height: 26),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_stories_outlined),
                  label: const Text('Discover more stories'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WriteScreen extends StatelessWidget {
  const WriteScreen({super.key, required this.data});

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Write',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontSize: 22),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 34),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CategoryTabs(labels: data.writeScreen.manageTabs),
          const SizedBox(height: 16),
          _CategoryTabs(labels: data.writeScreen.storyTabs, isCompact: true),
          const SizedBox(height: 18),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.filter_list_rounded, color: AppTheme.muted),
              const SizedBox(width: 8),
              Text(
                data.writeScreen.filterLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.arrow_downward_rounded, color: AppTheme.muted),
              const SizedBox(width: 8),
              Text(
                data.writeScreen.sortLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.writeScreen.emptyTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.writeScreen.emptyCta,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppTheme.brand),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.data});

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 22),
            ),
          ),
          const TabBar(
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.muted,
            indicatorColor: AppTheme.brand,
            tabs: [
              Tab(text: 'Story'),
              Tab(text: 'Community'),
              Tab(text: 'System'),
            ],
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              itemCount: data.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final item = data.notifications[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF4F4F4),
                      ),
                      child: Text(
                        'Inkitt',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.message,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.createdAt,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.data});

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      children: [
        ...data.menuSections.map(
          (section) => _MenuSection(
            section: section,
            onTap: (item) {
              if (item.route == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfileScreen(
                      profile: data.profile,
                      achievements: data.achievements,
                    ),
                  ),
                );
                return;
              }

              if (item.route == 'groups') {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GroupsFeedScreen(),
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MenuPlaceholderScreen(title: item.label),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.achievements,
  });

  final ProfileModel profile;
  final List<AchievementGroupModel> achievements;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF191B22), Color(0xFF2F3339)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8429D2),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -34),
                          child: Column(
                            children: [
                              Text(
                                profile.displayName,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontSize: 30,
                                      fontFamily: 'serif',
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.username,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ProfileCount(
                                        label: 'Following',
                                        value: profile.following,
                                      ),
                                    ),
                                    const _VerticalDividerLite(),
                                    Expanded(
                                      child: _ProfileCount(
                                        label: 'Followers',
                                        value: profile.followers,
                                      ),
                                    ),
                                    const _VerticalDividerLite(),
                                    Expanded(
                                      child: _ProfileCount(
                                        label: 'Blocked',
                                        value: profile.blocked,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              const _CategoryTabs(
                                labels: [
                                  'About',
                                  'Stories',
                                  'Wall',
                                  'Activity',
                                  'Reviews',
                                ],
                              ),
                              const SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.menu_book_outlined,
                                        color: Colors.pink,
                                        label: 'Chapters Read',
                                        value: '${profile.chaptersRead}',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.campaign_outlined,
                                        color: Colors.green,
                                        label: 'Social Karma',
                                        value: '${profile.socialKarma}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: _StatCard(
                                  icon: Icons.bubble_chart_outlined,
                                  color: Colors.cyan,
                                  label: 'Day Reading Streak',
                                  value: '${profile.dayStreak}',
                                  wide: true,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Reading Lists',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontSize: 18),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => AchievementsScreen(
                                              groups: achievements,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Achievements'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 215,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) =>
                                      _ReadingListCard(
                                        list: profile.readingLists[index],
                                        index: index,
                                      ),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 18),
                                  itemCount: profile.readingLists.length,
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.groups});

  final List<AchievementGroupModel> groups;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                _RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                Text(
                  'Achievements',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                ),
                const Spacer(),
                const SizedBox(width: 52),
              ],
            ),
            const SizedBox(height: 22),
            ...groups.map((group) => _AchievementGroup(group: group)),
          ],
        ),
      ),
    );
  }
}

class _AchievementGroup extends StatelessWidget {
  const _AchievementGroup({required this.group});

  final AchievementGroupModel group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.groupName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: group.items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) =>
                  _AchievementCard(item: group.items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.item});

  final AchievementItemModel item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _achievementColors(item.style),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.badgeValue,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: item.badgeValue.length > 3 ? 26 : 36,
                    color: item.style == 'silver'
                        ? Colors.black87
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            item.progressLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<Color> _achievementColors(String style) {
    switch (style) {
      case 'silver':
        return const [Color(0xFFF4F4F4), Color(0xFFB4B4B4)];
      case 'dark':
        return const [Color(0xFF565656), Color(0xFF171717)];
      default:
        return const [Color(0xFF343434), Color(0xFF000000)];
    }
  }
}

class GroupsFeedScreen extends StatelessWidget {
  const GroupsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080C),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'General',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '1 TA · GM',
                        style: TextStyle(
                          color: Color(0xFFA8A8B3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.video_call_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Row(
                children: [
                  Text(
                    'Posts',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(width: 44),
                  Text(
                    'Files',
                    style: TextStyle(color: Color(0xFF88889A), fontSize: 20),
                  ),
                  SizedBox(width: 44),
                  Text(
                    'More',
                    style: TextStyle(color: Color(0xFF88889A), fontSize: 20),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: const Color(0xFF716AFF), width: 98),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: const [
                  _DarkPostCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Polls',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose one drink for the BBQ event.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 14),
                        Text(
                          '○ Tea\n\n○ Cola\n\n○ Orange Juice\n\n○ Calpis Water',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  _DarkPostCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF1F1F2C),
                          child: Text(
                            'S',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This poll message can be ignored.',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF716AFF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Start a post'),
      ),
    );
  }
}

class _DarkPostCard extends StatelessWidget {
  const _DarkPostCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222230)),
      ),
      child: child,
    );
  }
}

class MenuPlaceholderScreen extends StatelessWidget {
  const MenuPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen is ready for backend actions.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.section, required this.onTap});

  final MenuSectionModel section;
  final ValueChanged<MenuItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.section.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                section.section,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 15),
              ),
            ),
          ...section.items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_iconFor(item.icon), color: AppTheme.ink, size: 28),
              title: Text(
                item.label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppTheme.muted,
              ),
              onTap: () => onTap(item),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'person':
        return Icons.person_outline_rounded;
      case 'bar_chart':
        return Icons.bar_chart_rounded;
      case 'groups':
        return Icons.groups_rounded;
      case 'help':
        return Icons.help_center_outlined;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'notifications':
        return Icons.notifications_none_rounded;
      case 'language':
        return Icons.translate_rounded;
      case 'favorite':
        return Icons.favorite_outline_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_outlined;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'cookie':
        return Icons.cookie_outlined;
      case 'description':
        return Icons.description_outlined;
      case 'lock':
        return Icons.lock_outline_rounded;
      case 'logout':
        return Icons.logout_rounded;
      default:
        return Icons.chevron_right_rounded;
    }
  }
}

class _ProfileCount extends StatelessWidget {
  const _ProfileCount({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _VerticalDividerLite extends StatelessWidget {
  const _VerticalDividerLite();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: const Color(0xFFE8E8E8));
  }
}

class _ReadingListCard extends StatelessWidget {
  const _ReadingListCard({required this.list, required this.index});

  final ReadingListModel list;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: index.isEven
                      ? const [Color(0xFFF8EDC5), Color(0xFFD9F0D2)]
                      : const [Color(0xFFF7E0D5), Color(0xFFDDD7FF)],
                ),
              ),
              child: Stack(
                children: List.generate(
                  6,
                  (tileIndex) => Positioned(
                    left: 12.0 + (tileIndex % 3) * 44,
                    top: 14.0 + (tileIndex ~/ 3) * 72,
                    child: SizedBox(
                      width: tileIndex == 0 ? 62 : 32,
                      height: tileIndex == 0 ? 96 : 52,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: tileIndex == 0 && list.coverPath.isNotEmpty
                            ? Image.asset(
                                list.coverPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.white.withValues(
                                  alpha: tileIndex == 0 ? 0.6 : 0.36,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            list.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          Text(
            '${list.storyCount} Stories',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.wide = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: wide ? 32 : 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryEntryTile extends StatelessWidget {
  const _LibraryEntryTile({required this.entry});

  final LibraryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniCover(book: entry.book),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.book.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${entry.book.author}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (entry.readingStatus.toLowerCase() == 'completed')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.done_all_rounded,
                            color: AppTheme.brand,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.readingStatus,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.brand),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppTheme.muted,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.readingStatus,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    Text(
                      '${entry.chapters} Chapters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF555555),
                      ),
                    ),
                    Text(
                      entry.primaryGenre,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF555555),
                      ),
                    ),
                    Text(
                      entry.secondaryGenre,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.brand),
          ),
        ],
      ),
    );
  }
}

class _MiniCover extends StatelessWidget {
  const _MiniCover({required this.book});

  final BookCardModel book;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(book.accentHex);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 74,
        height: 112,
        child: book.coverPath.isNotEmpty
            ? Image.asset(
                book.coverPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _MiniCoverFallback(color: color, title: book.title);
                },
              )
            : _MiniCoverFallback(color: color, title: book.title),
      ),
    );
  }
}

class _MiniCoverFallback extends StatelessWidget {
  const _MiniCoverFallback({required this.color, required this.title});

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.35) ?? color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(10),
      child: Text(
        title.split(' ').take(2).join('\n'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookCoverCard extends StatelessWidget {
  const _BookCoverCard({required this.book});

  final BookCardModel book;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(book.accentHex);

    return Container(
      width: 136,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            book.coverPath.isNotEmpty
                ? Image.asset(
                    book.coverPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _BookCoverFallback(color: color);
                    },
                  )
                : _BookCoverFallback(color: color),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xB3000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCoverFallback extends StatelessWidget {
  const _BookCoverFallback({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.42) ?? color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.labels, this.isCompact = false});

  final List<String> labels;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isCompact ? 38 : 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final selected = index == 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                labels[index],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? AppTheme.brand : AppTheme.muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 3,
                width: math.max(labels[index].length * 11.0, 74),
                color: selected ? AppTheme.brand : Colors.transparent,
              ),
            ],
          );
        },
        separatorBuilder: (context, index) =>
            SizedBox(width: isCompact ? 26 : 34),
        itemCount: labels.length,
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F8F8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 52, height: 52, child: Icon(icon)),
      ),
    );
  }
}

class _TabBarHeader extends SliverPersistentHeaderDelegate {
  const _TabBarHeader({required this.child});

  final Widget child;

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarHeader oldDelegate) => false;
}

Color _hexToColor(String hex) {
  final normalized = hex.replaceAll('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}
