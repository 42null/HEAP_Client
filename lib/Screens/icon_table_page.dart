import 'package:flutter/material.dart';

class IconTablePage extends StatelessWidget {
  const IconTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> icons = [
      {'name': 'favorite', 'icon': Icons.favorite},
      {'name': 'bookmark', 'icon': Icons.bookmark},
      {'name': 'star', 'icon': Icons.star},
      {'name': 'home', 'icon': Icons.home},
      {'name': 'settings', 'icon': Icons.settings},
      {'name': 'person', 'icon': Icons.person},
      {'name': 'search', 'icon': Icons.search},
      {'name': 'notifications', 'icon': Icons.notifications},
      {'name': 'mail', 'icon': Icons.mail},
      {'name': 'phone', 'icon': Icons.phone},
      {'name': 'share', 'icon': Icons.share},
      {'name': 'camera', 'icon': Icons.camera},
      {'name': 'edit', 'icon': Icons.edit},
      {'name': 'delete', 'icon': Icons.delete},
      {'name': 'add', 'icon': Icons.add},
      {'name': 'check', 'icon': Icons.check},
      {'name': 'error', 'icon': Icons.error},
      {'name': 'info', 'icon': Icons.info},
      {'name': 'warning', 'icon': Icons.warning},
      {'name': 'lock', 'icon': Icons.lock},
      {'name': 'playlist_add_circle', 'icon': Icons.playlist_add_circle},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon Table'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            runSpacing: 12.0,
            children: icons.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData),
                  const SizedBox(width: 4),
                  Text(item['name'] as String),
                  const SizedBox(width: 8),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
