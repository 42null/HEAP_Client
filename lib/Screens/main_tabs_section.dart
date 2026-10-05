import 'package:flutter/material.dart';

class MainTabsSection extends StatelessWidget {
  const MainTabsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // must match the number of tabs AND pages below
      child: Column(
        children: [
          // 1. Carousel
          SizedBox(
            height: 160,
            child: CarouselView(
              itemExtent: 300, // width of each card
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
              Tab(text: 'Items'),
              Tab(text: 'Daily'),
              Tab(text: 'Stats'),
            ],
          ),

          // 3. Pages that fill the rest
          const Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Items page')),
                Center(child: Text('Daily page')),
                Center(child: Text('Stats page')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}