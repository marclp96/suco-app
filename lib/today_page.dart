import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'nav.dart';
import 'journey_page.dart';
import 'live_home.dart';
import 'profile.dart';
import 'test_question.dart';
import 'app_drawer.dart';
import 'challenge_full.dart';
import 'team_list.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Map<String, dynamic>? _reflection;
  Map<String, dynamic>? _challenge;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // ✅ Get the most recent reflection that actually has an audio_url
      final resReflection = await supabase
          .from('reflections')
          .select()
          .not('audio_url', 'is', null)
          .not('audio_url', 'eq', '')
          .order('created_at', ascending: false)
          .limit(1);

      Map<String, dynamic>? reflection;
      if (resReflection.isNotEmpty) {
        reflection = Map<String, dynamic>.from(resReflection.first as Map);
      }

      // ✅ Latest daily challenge
      final resChallenge = await supabase
          .from('daily_challenge')
          .select()
          .order('created_at', ascending: false)
          .limit(1);

      Map<String, dynamic>? challenge;
      if (resChallenge.isNotEmpty) {
        challenge = Map<String, dynamic>.from(resChallenge.first as Map);
      }

      setState(() {
        _reflection = reflection;
        _challenge = challenge;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 🔑 Navegación inferior
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

  // 🔹 Greeting según hora + usuario Supabase
  Widget _buildGreetingSection() {
    final user = Supabase.instance.client.auth.currentUser;
    final supabase = Supabase.instance.client;

    return FutureBuilder(
      future: supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user!.id)
          .maybeSingle(),
      builder: (context, snapshot) {
        String greeting = _getGreeting();
        String name = 'there';

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data as Map<String, dynamic>?;
          if (data != null && data['full_name'] != null) {
            name = data['full_name'];
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$name ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const Text('👋', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Swipe down to refresh.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildGreetingSection(),
                        _buildHeroBanner(),
                        _buildDailyReflection(),
                        _buildDailyChallenge(),
                        _buildMindfulnessTestCarousel(),
                        const SizedBox(height: 100),
                      ],
                    ),
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

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg-image.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SUCO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '®',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Connect. Create. Celebrate.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyReflection() {
    final title = (_reflection?['title'] as String?)?.trim() ?? 'Untitled';
    final transcript = (_reflection?['transcript'] as String?)?.trim();
    final audioUrl = (_reflection?['audio_url'] as String?)?.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Jamie's Daily Reflection",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF404040),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (audioUrl == null || audioUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No audio available.'),
                        ),
                      );
                      return;
                    }

                    try {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                        setState(() => _isPlaying = false);
                      } else {
                        await _audioPlayer.stop();
                        await _audioPlayer.play(UrlSource(audioUrl));
                        setState(() => _isPlaying = true);

                        _audioPlayer.onPlayerComplete.listen((_) {
                          setState(() => _isPlaying = false);
                        });
                      }
                    } catch (e) {
                      debugPrint("❌ Error playing audio: $e");
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const Text(
                      "Listen to today's wisdom",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            (transcript == null || transcript.isEmpty)
                ? 'No transcript available for this reflection.'
                : transcript,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge() {
    final challengeTitle = (_challenge?['title'] as String?)?.trim();
    final titleToShow = (challengeTitle == null || challengeTitle.isEmpty)
        ? 'No challenge available today.'
        : challengeTitle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFCBFBC7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lightbulb_outline,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Challenge',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Join the movement',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                '🔥7',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            titleToShow,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChallengeFullPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "I'm In",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindfulnessTestCarousel() {
    final images = [
      'assets/images/carousel1.jpeg',
      'assets/images/carousel2.jpeg',
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: EdgeInsets.only(right: index == images.length - 1 ? 0 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mindfulness Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover your current mindfulness level and receive personalized recommendations to enhance your meditation journey.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBFBC7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TestQuestionPage(
                              testId:
                                  "06d15c08-1493-40da-907f-a8ce4eb11c77",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Take The Test',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
