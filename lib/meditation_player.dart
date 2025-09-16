import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'after_meditation_popup.dart';

class MeditationPlayerPage extends StatefulWidget {
  final String duration;

  const MeditationPlayerPage({super.key, required this.duration});

  @override
  State<MeditationPlayerPage> createState() => _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends State<MeditationPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 1, seconds: 45);

  @override
  void initState() {
    super.initState();

    // TODO: Replace with real meditation audio URL
    _audioPlayer.setSource(AssetSource("audio/meditation_sample.mp3"));

    _audioPlayer.onPositionChanged.listen((pos) {
      setState(() => _currentPosition = pos);
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      setState(() => _totalDuration = dur);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AfterMeditationPopup(),
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: Color(0xFF333333), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.white70, size: 26),
                      SizedBox(width: 16),
                      Icon(Icons.favorite_border,
                          color: Colors.white70, size: 26),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Title
            const Text("Be Here Now",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Active Meditation",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 40),

            // Play Button
            GestureDetector(
              onTap: () async {
                if (_isPlaying) {
                  await _audioPlayer.pause();
                } else {
                  await _audioPlayer.resume();
                }
                setState(() => _isPlaying = !_isPlaying);
              },
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBFBC7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Slider(
                    activeColor: const Color(0xFFCBFBC7),
                    inactiveColor: Colors.white24,
                    value: _currentPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (val) {
                      _audioPlayer.seek(Duration(seconds: val.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_currentPosition),
                          style: const TextStyle(color: Colors.white70)),
                      Text(_formatDuration(_totalDuration),
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
