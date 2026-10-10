import 'package:flutter/material.dart';
import '../models/item.dart';

class PillBox extends StatelessWidget {
  final Status status;
  final VoidCallback onTap;

  const PillBox({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Color(int.parse(status.hexColor.replaceFirst('#', '0xFF'))),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
