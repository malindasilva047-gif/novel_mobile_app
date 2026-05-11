import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/app_bootstrap.dart';
import '../../data/services/api_service.dart';
import 'discover_screen.dart';
import 'library_screen.dart';
import 'login_screen.dart';
import 'more_screen.dart';
import 'notifications_screen.dart';
import 'write_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final ApiService _apiService = const ApiService();
  int _selectedIndex = 1;
  AppBootstrap? _bootstrap;
  bool _loading = true;
  String _contentVersion = '';
  Timer? _syncTimer;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadBootstrap();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollContentVersion());
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBootstrap() async {
    final bootstrap = await _apiService.fetchBootstrap();
    final version = await _apiService.fetchContentVersion();
    if (!mounted) {
      return;
    }
    setState(() {
      _bootstrap = bootstrap;
      _contentVersion = version;
      _loading = false;
    });
  }

  Future<void> _pollContentVersion() async {
    if (_loading || _bootstrap == null) {
      return;
    }
    final latestVersion = await _apiService.fetchContentVersion();
    if (!mounted || latestVersion.isEmpty || latestVersion == _contentVersion) {
      return;
    }
    await _loadBootstrap();
  }

  Future<void> _continueLogin(String method, {String? email}) async {
    if (!mounted) {
      return;
    }
    setState(() => _loggedIn = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          method == 'email'
              ? 'Signed in with ${email ?? 'email'}'
              : 'Signed in with Google',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn) {
      return LoginScreen(onContinue: _continueLogin);
    }

    if (_loading || _bootstrap == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = <Widget>[
      LibraryScreen(
        data: _bootstrap!,
        apiService: _apiService,
        onOpenDiscover: () => setState(() => _selectedIndex = 1),
      ),
      DiscoverScreen(data: _bootstrap!, apiService: _apiService),
      WriteScreen(data: _bootstrap!, apiService: _apiService),
      NotificationsScreen(
        data: _bootstrap!,
        apiService: _apiService,
        onOpenDiscover: () => setState(() => _selectedIndex = 1),
      ),
      MoreScreen(data: _bootstrap!, apiService: _apiService),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 76,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
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
  }
}
