import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/app_bootstrap.dart';

class ApiService {
  const ApiService();

  static const String _overrideApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  String get _baseUrl {
    if (_overrideApiBaseUrl.isNotEmpty) {
      return _overrideApiBaseUrl;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Future<AppBootstrap> fetchBootstrap() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/bootstrap'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return AppBootstrap.fromMap(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}

    return AppBootstrap.fromMap(_fallbackData);
  }

  static final Map<String, dynamic> _fallbackData = <String, dynamic>{
    'discover_tabs': ['New', 'Popular', 'Fanfiction', 'Newsfeed'],
    'recently_updated': [
      {
        'id': 1,
        'title': 'Reclaimed by the Alpha',
        'author': 'L. Cross',
        'cover_path':
            'story_card_images/006575b1-f6b5-49b2-b3a4-6a9ef1a1e02e.jpg',
        'accent_hex': '#A06054',
      },
      {
        'id': 2,
        'title': 'The Unexpected Prisoner',
        'author': 'SpicySammy',
        'cover_path':
            'story_card_images/04d68518-aafb-497e-995e-10bc6e4bef90.jpg',
        'accent_hex': '#7661A8',
      },
      {
        'id': 3,
        'title': 'James',
        'author': 'Tamaska Tyne',
        'cover_path':
            'story_card_images/19eb26e8-6ee4-4010-8848-8f5779f602dd.jpg',
        'accent_hex': '#A98A52',
      },
      {
        'id': 4,
        'title': 'Soul Rebirth',
        'author': 'Inferno',
        'cover_path':
            'story_card_images/0d88ca6e-bdb9-4d45-b7f4-013f0ef843e5.jpg',
        'accent_hex': '#5B5AA8',
      },
    ],
    'recently_completed': [
      {
        'id': 5,
        'title': 'The Silence of Shadows',
        'author': 'Kurt Brunnhuber',
        'cover_path':
            'story_card_images/6290b4c8-83e9-4d5d-a740-06d4ec94d335.jpg',
        'accent_hex': '#674C6B',
      },
      {
        'id': 6,
        'title': 'What Now?',
        'author': 'Angela Lawece',
        'cover_path':
            'story_card_images/6a5c2a85-2d8c-498d-9153-1d72ec4005e4.jpg',
        'accent_hex': '#C69595',
      },
      {
        'id': 7,
        'title': 'Perpromenos',
        'author': 'Koyar Kora',
        'cover_path':
            'story_card_images/7d7d5cc8-5b0a-4821-9e57-3f58c36998b0.jpg',
        'accent_hex': '#8E9877',
      },
    ],
    'featured_book': {
      'id': 1,
      'title': 'Reclaimed by the Alpha: The Alpha\'s Hidden Heir',
      'author': 'L. Cross',
      'description':
          'Six years ago, Nick Blackwood broke my heart on Christmas morning when he believed a lie that destroyed us both. I disappeared, rebuilt my life, and raised his daughter alone.',
      'status_text': '2hr ago',
      'rating': 5,
      'genre': 'Romance',
      'cta': 'Read now',
    },
    'explore_topics': [
      {'name': 'Fanfiction', 'topic_count': 100},
      {'name': 'Fantasy', 'topic_count': 31},
      {'name': 'Poetry', 'topic_count': 14},
      {'name': 'Adventure', 'topic_count': 35},
      {'name': 'Horror', 'topic_count': 29},
      {'name': 'Thriller', 'topic_count': 35},
      {'name': 'Young Adult', 'topic_count': 0},
      {'name': 'LGBTQ+', 'topic_count': 0},
      {'name': 'Literary Fiction', 'topic_count': 0},
      {'name': 'Historical Fiction', 'topic_count': 0},
      {'name': 'Erotica', 'topic_count': 32},
      {'name': 'Mystery', 'topic_count': 32},
      {'name': 'SciFi', 'topic_count': 31},
      {'name': 'Humor', 'topic_count': 24},
    ],
    'library_entries': [
      {
        'book': {
          'id': 8,
          'title': 'Owned by the Lycan King (18+)',
          'author': 'E.F BONI',
          'cover_path':
              'story_card_images/8de846ae-c1cc-4e8b-a52e-e8aa48b6abb1.jpg',
          'accent_hex': '#8B523C',
        },
        'reading_status': 'Completed',
        'updated_text': '31 Chapters',
        'chapters': 31,
        'primary_genre': 'Romance',
        'secondary_genre': 'Erotica',
      },
      {
        'book': {
          'id': 9,
          'title': 'Lune',
          'author': 'Angela Lawece',
          'cover_path':
              'story_card_images/9e84fd30-5477-45f2-8c48-5c290f275856.jpg',
          'accent_hex': '#66738D',
        },
        'reading_status': '2wk ago',
        'updated_text': '4 Chapters',
        'chapters': 4,
        'primary_genre': 'Fantasy',
        'secondary_genre': 'SciFi',
      },
    ],
    'write_screen': {
      'manage_tabs': ['Manage Stories', 'Analytics'],
      'story_tabs': ['Submitted', 'Drafts'],
      'filter_label': 'All stories',
      'sort_label': 'Recently Updated',
      'empty_title': "You haven't submitted any story yet",
      'empty_cta': 'Submit Stories',
    },
    'notifications': [
      {
        'tab': 'System',
        'title': 'Inkitt',
        'message':
            'Earn some karma. Help this author today by reading their story!',
        'created_at': 'Tue Apr 19:11',
      },
    ],
    'menu_sections': [
      {
        'section': 'Profile',
        'items': [
          {'label': 'My Profile', 'icon': 'person', 'route': 'profile'},
          {'label': 'Reading Stats', 'icon': 'bar_chart', 'route': 'stats'},
        ],
      },
      {
        'section': 'Community',
        'items': [
          {'label': 'Groups', 'icon': 'groups', 'route': 'groups'},
        ],
      },
      {
        'section': 'Support',
        'items': [
          {'label': 'Help Center', 'icon': 'help', 'route': 'help'},
          {'label': 'Contact Us', 'icon': 'chat', 'route': 'contact'},
        ],
      },
      {
        'section': 'Settings',
        'items': [
          {
            'label': 'Notifications',
            'icon': 'notifications',
            'route': 'notifications',
          },
          {'label': 'App Language', 'icon': 'language', 'route': 'language'},
          {'label': 'Favourite Genres', 'icon': 'favorite', 'route': 'genres'},
          {
            'label': 'AI Content Review',
            'icon': 'auto_awesome',
            'route': 'ai-review',
          },
          {'label': 'Content Warnings', 'icon': 'warning', 'route': 'warnings'},
        ],
      },
      {
        'section': 'Legal',
        'items': [
          {
            'label': 'Manage Cookie Preferences',
            'icon': 'cookie',
            'route': 'cookies',
          },
          {
            'label': 'Terms of Service',
            'icon': 'description',
            'route': 'terms',
          },
          {'label': 'Privacy Policy', 'icon': 'lock', 'route': 'privacy'},
        ],
      },
      {
        'section': 'Change Accounts',
        'items': [
          {'label': 'Sign Out', 'icon': 'logout', 'route': 'logout'},
        ],
      },
    ],
    'profile': {
      'display_name': 'Sghj',
      'username': '@sghj',
      'following': 1,
      'followers': 0,
      'blocked': 0,
      'chapters_read': 0,
      'social_karma': 0,
      'day_streak': 0,
      'reading_lists': [
        {
          'name': 'Currently Reading',
          'story_count': 2,
          'cover_path':
              'story_card_images/8de846ae-c1cc-4e8b-a52e-e8aa48b6abb1.jpg',
        },
        {
          'name': 'Archived / Finished Books',
          'story_count': 0,
          'cover_path':
              'story_card_images/6290b4c8-83e9-4d5d-a740-06d4ec94d335.jpg',
        },
      ],
    },
    'achievements': [
      {
        'group_name': 'Lifetime Reviews Given',
        'items': [
          {
            'title': 'Reviewer-in-Training',
            'subtitle': '0/1 Reviews Left',
            'progress_label': '0/1 Reviews Left',
            'badge_value': '1',
            'style': 'silver',
          },
          {
            'title': 'Community Voice',
            'subtitle': '0/2 Reviews Left',
            'progress_label': '0/2 Reviews Left',
            'badge_value': '2',
            'style': 'silver',
          },
          {
            'title': 'Story Critic',
            'subtitle': '0/3 Reviews Left',
            'progress_label': '0/3 Reviews Left',
            'badge_value': '3',
            'style': 'silver',
          },
        ],
      },
      {
        'group_name': 'Lifetime Words Published',
        'items': [
          {
            'title': 'Ink Sprout',
            'subtitle': '0/1000 Words Published',
            'progress_label': '0/1000 Words Published',
            'badge_value': '1000',
            'style': 'dark',
          },
          {
            'title': 'Wordsmith',
            'subtitle': '0/5000 Words Published',
            'progress_label': '0/5000 Words Published',
            'badge_value': '5000',
            'style': 'dark',
          },
          {
            'title': 'Pen Prodigy',
            'subtitle': '0/10000 Words Published',
            'progress_label': '0/10000 Words Published',
            'badge_value': '10000',
            'style': 'dark',
          },
        ],
      },
      {
        'group_name': 'Lifetime Reading',
        'items': [
          {
            'title': 'Page Flipper',
            'subtitle': '0/2 Chapters Read',
            'progress_label': '0/2 Chapters Read',
            'badge_value': '2',
            'style': 'ink',
          },
          {
            'title': 'Book Explorer',
            'subtitle': '0/5 Chapters Read',
            'progress_label': '0/5 Chapters Read',
            'badge_value': '5',
            'style': 'ink',
          },
          {
            'title': 'Reading Enthusiast',
            'subtitle': '0/10 Chapters Read',
            'progress_label': '0/10 Chapters Read',
            'badge_value': '10',
            'style': 'ink',
          },
        ],
      },
    ],
  };
}
