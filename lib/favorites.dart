import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_drawer.dart';
import 'today_page.dart';
import 'meditation_player.dart';
import 'test_question.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final supabase = Supabase.instance.client;
  String selectedFilter = "All";
  List<Map<String, dynamic>> favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final favs = await supabase
          .from('favorites')
          .select('id, content_type, content_id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> results = [];

      for (final fav in favs) {
        final type = fav['content_type'];
        final id = fav['content_id'];
        Map<String, dynamic>? content;

        if (type == 'reflection') {
          content = await supabase
              .from('reflections')
              .select('id, title, transcript')
              .eq('id', id)
              .maybeSingle();
        } else if (type == 'meditation') {
          content = await supabase
              .from('meditations')
              .select('id, title, description')
              .eq('id', id)
              .maybeSingle();
        } else if (type == 'test') {
          content = await supabase
              .from('tests')
              .select('id, title, description')
              .eq('id', id)
              .maybeSingle();
        }

        if (content != null) {
          results.add({
            'type': type,
            'title': content['title'] ?? 'Untitled',
            'description': content['description'] ??
                content['transcript'] ??
                '',
            'id': content['id'],
          });
        }
      }

      setState(() {
        favorites = results;
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading favorites: $e');
      setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filteredFavorites {
    if (selectedFilter == "All") return favorites;
    return favorites
        .where((f) => f['type'].toString().toLowerCase() ==
            selectedFilter.toLowerCase())
        .toList();
  }

  void _openFavorite(Map<String, dynamic> fav) {
    if (fav['type'] == 'reflection') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TodayPage()),
      );
    } else if (fav['type'] == 'meditation') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeditationPlayerPage(
            audioUrl: '', // ⚠️ deberías obtener el audio real de Supabase
            duration: '20 min',
            meditationId: fav['id'],
          ),
        ),
      );
    } else if (fav['type'] == 'test') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TestQuestionPage(testId: fav['id']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ["All", "Reflection", "Meditation", "Test"];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF333333),
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
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF333333),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => selectedFilter = filter),
                      selectedColor: const Color(0xFFCBFBC7),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: const Color(0xFF2A2A2A),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFCBFBC7),
                      ),
                    )
                  : filteredFavorites.isEmpty
                      ? const Center(
                          child: Text(
                            "No favorites yet 💔",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final fav = filteredFavorites[index];
                            return ListTile(
                              title: Text(
                                fav['title'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                fav['description'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              ),
                              onTap: () => _openFavorite(fav),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
