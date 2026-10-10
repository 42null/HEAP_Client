import 'package:flutter/material.dart';

import 'core_pages/main_tabs_section.dart';

class CorePage extends StatefulWidget {
  const CorePage({super.key});

  @override
  State<CorePage> createState() => _CorePageState();
}

class _CorePageState extends State<CorePage> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  // One entry per rail destination, same order as `destinations` below
  final List<Widget> _sections = const [
    MainTabsSection(),
    Center(child: Text('Second section')),
    Center(child: Text('Third section')),
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
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('First'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark),
                label: Text('Second'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: Text('Third'),
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