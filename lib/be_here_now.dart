import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_drawer.dart';
import 'duration_popup.dart';
import 'widgets/vimeo_player_widget.dart';
import 'test_question.dart'; // 👈 Import del test

class BeHereNowPage extends StatefulWidget {
  const BeHereNowPage({super.key});

  @override
  State<BeHereNowPage> createState() => _BeHereNowPageState();
}

class _BeHereNowPageState extends State<BeHereNowPage> {
  String? _videoId;
  String? _beHereNowAudioUrl;
  String? _deepSleepAudioUrl;
  bool _loadingVideo = true;

  @override
  void initState() {
    super.initState();
    _fetchVideoFromSupabase();
    _fetchBeHereNowAudio();
    _fetchDeepSleepAudio();
  }

  // 🔹 Intro video
  Future<void> _fetchVideoFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('meditations')
          .select(
              'title, intro_video(id, media_versions!fk_media_versions_media_id(url))')
          .eq('title', 'Be Here Now')
          .single();

      final introVideo = response['intro_video'];
      if (introVideo != null &&
          introVideo['media_versions'] != null &&
          introVideo['media_versions'].isNotEmpty) {
        final url = introVideo['media_versions'][0]['url'] as String;
        final regex = RegExp(r'vimeo\.com/(\d+)');
        final match = regex.firstMatch(url);
        if (match != null) {
          setState(() {
            _videoId = match.group(1);
            _loadingVideo = false;
          });
        } else {
          setState(() => _loadingVideo = false);
        }
      } else {
        setState(() => _loadingVideo = false);
      }
    } catch (e) {
      debugPrint("❌ Error fetching video: $e");
      setState(() => _loadingVideo = false);
    }
  }

  // 🔹 Audio Be Here Now
  Future<void> _fetchBeHereNowAudio() async {
    try {
      final supabase = Supabase.instance.client;

      final res = await supabase
          .from('meditations')
          .select('media_content')
          .eq('title', 'Be Here Now')
          .single();

      final List<dynamic> mediaIds = res['media_content'] ?? [];
      if (mediaIds.isNotEmpty) {
        final versions = await supabase
            .from('media_versions')
            .select('url')
            .inFilter('media_id', mediaIds);

        if (versions.isNotEmpty) {
          setState(() => _beHereNowAudioUrl = versions[0]['url'] as String);
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching Be Here Now audio: $e");
    }
  }

  // 🔹 Audio Deep Sleep
  Future<void> _fetchDeepSleepAudio() async {
    try {
      final supabase = Supabase.instance.client;

      final res = await supabase
          .from('meditations')
          .select('media_content')
          .eq('title', 'Deep Sleep')
          .single();

      final List<dynamic> mediaIds = res['media_content'] ?? [];
      if (mediaIds.isNotEmpty) {
        final versions = await supabase
            .from('media_versions')
            .select('url')
            .inFilter('media_id', mediaIds);

        if (versions.isNotEmpty) {
          setState(() => _deepSleepAudioUrl = versions[0]['url'] as String);
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching Deep Sleep audio: $e");
    }
  }

  // 🔹 Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Text(
            "Be Here Now",
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
                child: const Icon(Icons.menu, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Hero Video Section (Vimeo)
  Widget _buildHeroVideo() {
    if (_loadingVideo) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFFCBFBC7)),
        ),
      );
    }

    if (_videoId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "⚠️ No video available",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // ✅ VimeoPlayerWidget actualizado (funciona en iOS / Android / Web)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: VimeoPlayerWidget(
        videoId: _videoId!,
        autoPlay: true,
        loop: false, // Puedes poner true si quieres que repita
      ),
    );
  }

  // 🔹 Intro Text
  Widget _buildIntroText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Introduction",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Introduction to becoming one with the here and now, to start your SUCO journey",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Video Sections
  Widget _buildVideoSection({
    required String title,
    required List<Map<String, String>> cards,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
          Column(
            children: cards.map((card) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (card["title"] == "Be Here Now" &&
                        _beHereNowAudioUrl != null) {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            DurationPopup(audioUrl: _beHereNowAudioUrl!),
                      );
                    } else if (card["title"] == "Deep Sleep" &&
                        _deepSleepAudioUrl != null) {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            DurationPopup(audioUrl: _deepSleepAudioUrl!),
                      );
                    } else if (card["title"] == "Mindfulness Test") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TestQuestionPage(
                            testId: "06d15c08-1493-40da-907f-a8ce4eb11c77",
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.asset(
                            card["image"]!,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card["title"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card["subtitle"]!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCBFBC7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.black, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
            _buildHeader(context),
            _buildHeroVideo(),
            _buildIntroText(),
            _buildVideoSection(
              title: "Active Meditation",
              cards: [
                {
                  "title": "Be Here Now",
                  "subtitle": "Deep meditation",
                  "image": "assets/images/active-meditation.jpeg",
                },
              ],
            ),
            _buildVideoSection(
              title: "Sleep Ritual",
              cards: [
                {
                  "title": "Deep Sleep",
                  "subtitle": "Deep meditation",
                  "image": "assets/images/sleep-ritual.jpeg",
                },
              ],
            ),
            _buildVideoSection(
              title: "Soundscape",
              cards: [
                {
                  "title": "Binaural Beats",
                  "subtitle": "Deep meditation",
                  "image": "assets/images/soundscape.jpeg",
                },
              ],
            ),
            _buildVideoSection(
              title: "Test Center",
              cards: [
                {
                  "title": "Mindfulness Test",
                  "subtitle": "Check your awareness level",
                  "image": "assets/images/breathwork-session.jpeg",
                },
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
