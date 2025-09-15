import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'app_drawer.dart'; // 👈 Drawer conectado

class BeHereNowPage extends StatefulWidget {
  const BeHereNowPage({super.key});

  @override
  State<BeHereNowPage> createState() => _BeHereNowPageState();
}

class _BeHereNowPageState extends State<BeHereNowPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse("https://www.youtube.com/watch?v=xyshPstbe-k"),
    )..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true, // ▶️ autoplay activado
      looping: false,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: true,
      showControls: true, // 🎛️ controles visibles
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFCBFBC7),
        handleColor: Colors.white,
        bufferedColor: Colors.grey,
        backgroundColor: Colors.black26,
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

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
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
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
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
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

  Widget _buildHeroVideo() {
    if (!_videoController.value.isInitialized) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFFCBFBC7)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildIntroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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
              return Container(
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
