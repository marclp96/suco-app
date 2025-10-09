import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart'; // 🟢 SDK Vimeo
import 'nav.dart';
import 'today_page.dart';
import 'live_home.dart';
import 'profile.dart';
import 'be_here_now.dart';
import 'app_drawer.dart';
import 'team_list.dart';
import 'test_question.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  int _selectedIndex = 2;
  String? _videoUrl;
  bool _loadingVideo = true;

  List<String> _completedItems = [];
  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadIntroVideo();
    _loadUserProgress();
  }

  /// 🎬 Cargar vídeo de introducción desde Supabase
  Future<void> _loadIntroVideo() async {
    try {
      final response = await Supabase.instance.client
          .from('journey')
          .select('intro_video_url')
          .maybeSingle();

      if (response != null && response['intro_video_url'] != null) {
        final url = response['intro_video_url'] as String;
        final regex = RegExp(r'vimeo\.com/(\d+)');
        final match = regex.firstMatch(url);

        if (match != null) {
          final videoId = match.group(1)!;
          setState(() {
            _videoUrl = 'https://player.vimeo.com/video/$videoId';
            _loadingVideo = false;
          });
        } else {
          setState(() => _loadingVideo = false);
        }
      } else {
        setState(() => _loadingVideo = false);
      }
    } catch (e) {
      debugPrint("❌ Error loading intro video: $e");
      setState(() => _loadingVideo = false);
    }
  }

  /// 🧘 Cargar progreso (meditaciones y tests)
  Future<void> _loadUserProgress() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('journey_session_log')
          .select('meditation_id')
          .eq('user_id', user.id)
          .eq('completed', true);

      setState(() {
        _completedItems =
            List<String>.from(response.map((e) => e['meditation_id'].toString()));
        _loadingProgress = false;
      });
    } catch (e) {
      debugPrint("⚠️ Error loading user progress: $e");
      setState(() => _loadingProgress = false);
    }
  }

  Future<void> _markMeditationComplete(String meditationId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('journey_session_log').insert({
        'user_id': user.id,
        'meditation_id': meditationId,
        'completed': true,
        'duration': 15,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _completedItems.add(meditationId);
      });
    } catch (e) {
      debugPrint("⚠️ Error saving meditation progress: $e");
    }
  }

  Future<void> _markTestComplete(String testId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('journey_session_log').insert({
        'user_id': user.id,
        'meditation_id': testId,
        'completed': true,
        'duration': 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        _completedItems.add(testId);
      });
    } catch (e) {
      debugPrint("⚠️ Error saving test progress: $e");
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

  /// 🎥 Mostrar intro video (diálogo modal)
  void _showIntroVideo(BuildContext context) {
    if (_videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No intro video found')),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Intro Video",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VimeoVideoPlayer(
                    url: _videoUrl!,
                    autoPlay: true,
                  ),
                ),
              ),
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

  Future<void> _openMeditation(BuildContext context, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeHereNowPage()),
    );
    await _markMeditationComplete(title);
  }

  Future<void> _openTest(BuildContext context, String testId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TestQuestionPage(testId: testId)),
    );
    await _markTestComplete(testId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: _loadingProgress
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFCBFBC7)))
            : ListView(
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
                        "locked": false,
                        "type": "meditation"
                      },
                      {
                        "title": "Connect to Self",
                        "subtitle": "Learn to connect",
                        "locked": true,
                        "type": "meditation"
                      },
                      {
                        "title": "Connect to Others",
                        "subtitle": "Learn to empathize",
                        "locked": true,
                        "type": "meditation"
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
                        "locked": true,
                        "type": "meditation"
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
          onPressed: _loadingVideo ? null : () => _showIntroVideo(context),
          icon: const Icon(Icons.play_arrow, color: Colors.black),
          label: Text(
            _loadingVideo ? "Loading..." : "Watch Intro",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCBFBC7),
            disabledBackgroundColor: Colors.grey.shade600,
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
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
          Column(
            children: lessons.map((lesson) {
              final locked = lesson['locked'] as bool;
              final title = lesson['title'];
              final completed = _completedItems.contains(title);
              final type = lesson['type'] ?? 'meditation';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      locked ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: completed
                      ? Border.all(color: const Color(0xFFCBFBC7), width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyle(
                                  color: completed
                                      ? const Color(0xFFCBFBC7)
                                      : locked
                                          ? Colors.white54
                                          : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(lesson['subtitle'],
                              style: TextStyle(
                                  color:
                                      locked ? Colors.white38 : Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (locked) return;
                        if (type == 'test') {
                          await _openTest(context, title);
                        } else {
                          await _openMeditation(context, title);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: locked
                              ? Colors.transparent
                              : completed
                                  ? const Color(0xFFCBFBC7)
                                  : const Color(0xFF333333),
                          shape: BoxShape.circle,
                          border: locked
                              ? Border.all(color: Colors.white30, width: 1)
                              : null,
                        ),
                        child: Icon(
                          locked
                              ? Icons.lock
                              : completed
                                  ? Icons.check
                                  : Icons.arrow_forward,
                          color: locked
                              ? Colors.white54
                              : completed
                                  ? Colors.black
                                  : Colors.white,
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
