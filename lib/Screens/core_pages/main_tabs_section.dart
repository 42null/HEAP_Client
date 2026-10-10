import 'package:flutter/material.dart';

// Screens
import '../item_list_screen.dart';
import '../edit_screen.dart';

// Data models
import '../../models/item.dart';

class MainTabsSection extends StatefulWidget {
  const MainTabsSection({super.key});

  @override
  State<MainTabsSection> createState() => _MainTabsSectionState();
}

class _MainTabsSectionState extends State<MainTabsSection> {
  Item? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // must match the number of tabs AND pages below
      child: Column(
        children: [
          // 1. Carousel
          SizedBox(
            height: 160,
            child: CarouselView(
              itemExtent: 600, // width of each card
              children: List.generate(
                5,
                    (i) => Container(
                  color: Colors.primaries[i],
                  alignment: Alignment.center,
                  child: Text('Card ${i + 1}'),
                ),
              ),
            ),
          ),

          // 2. Tabs
          const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Projects'),
              Tab(text: 'Items'),
              Tab(text: 'Edit'),
            ],
          ),

          // 3. Pages that fill the rest
          Expanded(
            child: TabBarView(
              children: [
                const Center(child: Text('For You')),
                const Center(child: Text('Projects')),
                Builder(
                  builder: (BuildContext context) {
                    return ItemListScreen(
                      onItemSelected: (item) {
                        setState(() {
                          _selectedItem = item;
                        });
                        DefaultTabController.of(context).animateTo(3);
                      },
                    );
                  },
                ),
                EditScreen(
                  key: _selectedItem != null ? ValueKey(_selectedItem!.id) : const ValueKey('new_item'),
                  item: _selectedItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
