import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav.dart';
import 'today_page.dart';
import 'live_home.dart';
import 'profile.dart';
import 'be_here_now.dart';
import 'app_drawer.dart';
import 'team_list.dart';
import 'widgets/vimeo_player_widget.dart'; // ✅ ruta correcta

class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  int _selectedIndex = 2;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _loadIntroVideo();
  }

  Future<void> _loadIntroVideo() async {
    final response = await Supabase.instance.client
        .from('journey')
        .select('intro_video_url')
        .maybeSingle();

    if (response != null && response['intro_video_url'] != null) {
      final url = response['intro_video_url'] as String;
      final regex = RegExp(r'vimeo\.com/(\d+)');
      final match = regex.firstMatch(url);
      setState(() {
        _videoId = match != null ? match.group(1)! : url;
      });
    }
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const TodayPage();
        break;
      case 1:
        nextPage = const TeamListPage();
        break;
      case 2:
        nextPage = const JourneyPage();
        break;
      case 3:
        nextPage = const LiveHomePage();
        break;
      default:
        nextPage = const TodayPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  void _showIntroVideo(BuildContext context) {
    if (_videoId == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Intro Video",
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Fondo difuminado
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),

              // Vídeo centrado (igual que en Be Here Now)
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VimeoPlayerWidget(
                    videoId: _videoId!,
                    autoPlay: true,
                  ),
                ),
              ),

              // Botón de cerrar
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          children: [
            _buildHeader(),
            _buildHeroBanner(),
            _buildIntroText(),
            _buildWatchIntroButton(),
            const SizedBox(height: 16),
            _buildSeriesSection(
              title: "Connect Series",
              description:
                  "Learn to cultivate deeper relationships with yourself and others through mindful presence and authentic communication practices.",
              lessons: [
                {
                  "title": "Be Here Now",
                  "subtitle": "Learn to be present",
                  "locked": false
                },
                {
                  "title": "Connect to Self",
                  "subtitle": "Learn to Connect",
                  "locked": true
                },
                {
                  "title": "Connect to Others",
                  "subtitle": "Learn to empathize",
                  "locked": true
                },
              ],
            ),
            _buildSeriesSection(
              title: "Create Series",
              description:
                  "Learn to let go, to destress, to awaken your emotional intelligence, finding your personal state of Flow.",
              lessons: [
                {
                  "title": "Let Go",
                  "subtitle": "Learn to let go",
                  "locked": true
                },
                {"title": "Feel", "subtitle": "Learn to feel", "locked": true},
                {"title": "Play", "subtitle": "Learn to play", "locked": true},
              ],
            ),
            _buildSeriesSection(
              title: "Celebrate Series",
              description:
                  "Cultivate deep gratitude, body appreciation, and unity consciousness. Through celebration practices, we release endorphins and feel joy.",
              lessons: [
                {
                  "title": "The Miracle of You",
                  "subtitle": "Learn about yourself",
                  "locked": true
                },
                {"title": "Unity", "subtitle": "Learn to unify", "locked": true},
                {
                  "title": "Gratitude for the Now",
                  "subtitle": "Learn to be grateful",
                  "locked": true
                },
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
      floatingActionButton: AppCenterFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good morning',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Marc 👋',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/venn.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        "The 9 Meditations Journey\n\nToday, let’s explore the profound connection between sound and consciousness. When we align our internal frequency with the vibrations of the universe, we become conduits for transformation.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildWatchIntroButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _showIntroVideo(context),
          icon: const Icon(Icons.play_arrow, color: Colors.black),
          label: const Text(
            "Watch Intro",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCBFBC7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesSection({
    required String title,
    required String description,
    required List<Map<String, dynamic>> lessons,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: lessons.map((lesson) {
              final locked = lesson['locked'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: locked
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson['title'],
                            style: TextStyle(
                              color: locked ? Colors.white54 : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson['subtitle'],
                            style: TextStyle(
                              color: locked ? Colors.white38 : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!locked && lesson['title'] == "Be Here Now") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BeHereNowPage()),
                          );
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: locked
                              ? Colors.transparent
                              : const Color(0xFFCBFBC7),
                          shape: BoxShape.circle,
                          border: locked
                              ? Border.all(color: Colors.white30, width: 1)
                              : null,
                        ),
                        child: Icon(
                          locked ? Icons.lock : Icons.play_arrow,
                          color: locked ? Colors.white54 : Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
