import 'package:flutter/material.dart';

import 'core_pages/main_tabs_section.dart';
import 'icon_table_page.dart';
import 'queue_tracker_screen.dart';

class CorePage extends StatefulWidget {
  const CorePage({super.key});

  @override
  State<CorePage> createState() => _CorePageState();
}

class _CorePageState extends State<CorePage> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  // One entry per rail destination, same order as `destinations` below
    final List<Widget> _sections = [
    MainTabsSection(),
    const QueueTrackerScreen(),
    const IconTablePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            extended: _isExtended,
            labelType: _isExtended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            leading: FloatingActionButton(
              elevation: 0,
              onPressed: () {
                setState(() => _isExtended = !_isExtended);
              },
              child: Icon(_isExtended ? Icons.arrow_left : Icons.arrow_right),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text('Projects'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.playlist_add_circle_outlined),
                selectedIcon: Icon(Icons.playlist_add_circle),
                label: Text('Queue'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.palette_outlined),
                selectedIcon: Icon(Icons.palette),
                label: Text('Icons'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _sections,
            ),
          ),
        ],
      ),
    );
  }
}