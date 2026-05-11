import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_bootstrap.dart';
import '../../data/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.apiService,
  });

  final ProfileModel profile;
  final ApiService apiService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Gradient Header
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A3A52), Color(0xFF2D5A7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        widget.profile.username.substring(0, 1).toUpperCase(),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.profile.username,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${widget.profile.username.toLowerCase().replaceAll(' ', '_')}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Stats Row
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  label: 'Following',
                  value: widget.profile.following.toString(),
                ),
                _StatCard(
                  label: 'Followers',
                  value: widget.profile.followers.toString(),
                ),
                _StatCard(label: 'Blocked', value: '0'),
              ],
            ),
          ),
        ),

        // Tabs
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabHeaderDelegate(
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.brand,
              unselectedLabelColor: AppTheme.muted,
              indicatorColor: AppTheme.brand,
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Stories'),
                Tab(text: 'Wall'),
                Tab(text: 'Activity'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
        ),

        // Tab Content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _AboutTab(
                profile: widget.profile,
                apiService: widget.apiService,
              ),
              const _StoriesTab(),
              const _WallTab(),
              const _ActivityTab(),
              const _ReviewsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.brand,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.profile, required this.apiService});

  final ProfileModel profile;
  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Section
        Text(
          'Stats',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatsPanel(
              icon: Icons.menu_book_outlined,
              label: 'Chapters Read',
              value: profile.chaptersRead.toString(),
              color: const Color(0xFF667EEA),
            ),
            _StatsPanel(
              icon: Icons.favorite_outline,
              label: 'Social Karma',
              value: profile.socialKarma.toString(),
              color: const Color(0xFFFF6B9D),
            ),
            _StatsPanel(
              icon: Icons.local_fire_department_outlined,
              label: 'Day Streak',
              value: profile.dayStreak.toString(),
              color: const Color(0xFFFFB84D),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Reading Lists Section
        Text(
          'Reading Lists',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        if (profile.readingLists.isEmpty)
          Text(
            'No reading lists yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: profile.readingLists.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _ReadingListPreview(
                list: profile.readingLists[index],
                apiService: apiService,
              ),
            ),
          ),
        const SizedBox(height: 32),

        // About me
        Text(
          'About Me',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'No bio added yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: const Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                color: AppTheme.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingListPreview extends StatelessWidget {
  const _ReadingListPreview({required this.list, required this.apiService});

  final ReadingListModel list;
  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF5F5F5),
              ),
              child: list.coverPath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        apiService.resolveAssetUrl(list.coverPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.library_books_outlined,
                      color: AppTheme.muted.withValues(alpha: 0.3),
                      size: 48,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            list.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _StoriesTab extends StatelessWidget {
  const _StoriesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 48,
            color: AppTheme.muted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No published stories yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _WallTab extends StatelessWidget {
  const _WallTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppTheme.muted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No wall posts yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: AppTheme.muted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: AppTheme.muted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  _TabHeaderDelegate({required this.child});

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
    return Container(color: Colors.white, child: child);
  }

  @override
  bool shouldRebuild(_TabHeaderDelegate oldDelegate) => false;
}
