import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF1A1A1A),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(Icons.home_outlined, "Today", 0),
            _buildItem(Icons.people_outline, "Team", 1),
            const SizedBox(width: 40), // espacio para el FAB
            _buildItem(Icons.music_note_outlined, "Journey", 2),
            _buildItem(Icons.confirmation_num_outlined, "Live", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFCBFBC7) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFCBFBC7) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AppCenterFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AppCenterFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFCBFBC7),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Image.network(
            'assets/images/Suco-DarkGreyIcon.png',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}