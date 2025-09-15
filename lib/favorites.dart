import 'package:flutter/material.dart';
import 'app_drawer.dart'; // 👈 Import del Drawer

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _selectedFilter = "All";

  final List<Map<String, dynamic>> _favorites = [
    {
      "title": "Finding Peace in Uncertainty",
      "type": "Daily Reflection",
      "description":
          "Embrace the unknown as an opportunity for growth. When we learn to find comfort in",
      "date": "Jan 15, 2025",
      "duration": null,
    },
    {
      "title": "Morning Mindfulness",
      "type": "Meditation",
      "description":
          "Start your day with intention and clarity through this guided breathing meditation designed for",
      "date": "Jan 14, 2025",
      "duration": "10 min",
    },
    {
      "title": "The Science of Gratitude",
      "type": "Fact",
      "description":
          "Research shows that practicing gratitude for just minutes daily can increase happiness levels by",
      "date": "Jan 13, 2025",
      "duration": null,
    },
    {
      "title": "Body Scan Relaxation",
      "type": "Meditation",
      "description":
          "Release tension and stress with this progressive body scan meditation that guides you through",
      "date": "Jan 12, 2025",
      "duration": "15 min",
    },
    {
      "title": "Lessons from Nature",
      "type": "Daily Reflection",
      "description":
          "Trees teach us patience and resilience. They bend without breaking, grow slowly but surely,",
      "date": "Jan 11, 2025",
      "duration": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == "All"
        ? _favorites
        : _favorites
            .where((item) =>
                item["type"].toString().contains(_selectedFilter))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(), // 👈 Drawer conectado
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final fav = filtered[index];
                  return _buildFavoriteCard(fav);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          const Text(
            "My Favorites",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 👇 Botón hamburguesa que abre el Drawer
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.menu, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ["All", "Reflections", "Challenges", "Meditations"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = f;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFCBFBC7)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> fav) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & type
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.favorite_border,
                  color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fav["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fav["type"],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fav["description"],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    fav["date"],
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  if (fav["duration"] != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      fav["duration"],
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ],
              ),
              Icon(
                fav["type"] == "Meditation"
                    ? Icons.play_circle_fill
                    : Icons.bookmark_border,
                color: Colors.white70,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
