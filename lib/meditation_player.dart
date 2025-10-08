import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'after_meditation_popup.dart';
import 'favorite_button.dart';

class MeditationPlayerPage extends StatefulWidget {
  final String audioUrl;
  final String duration;
  final String? meditationId;

  const MeditationPlayerPage({
    super.key,
    required this.audioUrl,
    required this.duration,
    this.meditationId,
  });

  @override
  State<MeditationPlayerPage> createState() => _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends State<MeditationPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late Duration _sessionDuration;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    final minutes = int.tryParse(widget.duration.split(" ")[0]) ?? 20;
    _sessionDuration = Duration(minutes: minutes);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.setSourceUrl(widget.audioUrl);

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _totalDuration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
      if (p >= _sessionDuration) _stopSession();
    });

    _audioPlayer.onPlayerComplete.listen((_) => _stopSession());

    _play();
  }

  Future<void> _play() async {
    await _audioPlayer.resume();
    setState(() => _isPlaying = true);
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _stopSession() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        debugPrint("⚠️ No user logged in, skipping session log.");
        return;
      }

      await supabase.from('journey_session_log').insert({
        'user_id': user.id,
        'meditation_id': widget.meditationId,
        'duration': _sessionDuration.inMinutes,
        'date': DateTime.now().toIso8601String(),
        'completed': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint("✅ Meditation session saved in journey_session_log");
    } catch (e) {
      debugPrint("❌ Error saving session: $e");
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            AfterMeditationPopup(duration: _sessionDuration.inMinutes),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF333333),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        title: const Text(
          "Meditation Player",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Portada
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
                image: const DecorationImage(
                  image: AssetImage("assets/images/active-meditation.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Barra de progreso con el corazón al lado derecho
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    activeColor: const Color(0xFFCBFBC7),
                    inactiveColor: Colors.white24,
                    value: _position.inSeconds
                        .clamp(0, _sessionDuration.inSeconds)
                        .toDouble(),
                    max: _sessionDuration.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final pos = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(pos);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // ❤️ Siempre visible — seguro ante IDs vacíos
                FavoriteButton(
                  contentType: 'meditation',
                  contentId: widget.meditationId ?? 'unknown',
                ),
              ],
            ),

            // 🔹 Tiempo actual y duración total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_position),
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  _formatTime(_sessionDuration),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🔹 Botón play/pause
            IconButton(
              iconSize: 64,
              icon: Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: const Color(0xFFCBFBC7),
              ),
              onPressed: () {
                if (_isPlaying) {
                  _pause();
                } else {
                  _play();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
