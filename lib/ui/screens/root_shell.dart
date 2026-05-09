import 'package:flutter/material.dart';

import '../../data/models/app_bootstrap.dart';
import '../../data/services/api_service.dart';
import 'discover_screen.dart';
import 'library_screen.dart';
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
                  'Unable to load app data. Check backend connection.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final bootstrap = snapshot.data!;
        final pages = <Widget>[
          LibraryScreen(data: bootstrap, apiService: _apiService),
          DiscoverScreen(data: bootstrap, apiService: _apiService),
          WriteScreen(data: bootstrap, apiService: _apiService),
          NotificationsScreen(data: bootstrap, apiService: _apiService),
          MoreScreen(data: bootstrap),
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
      },
    );
  }
}
