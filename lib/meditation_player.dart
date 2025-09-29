import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MeditationPlayerPage extends StatefulWidget {
  final String audioUrl;
  final String duration; // "15 minutes", "20 minutes", "30 minutes"

  const MeditationPlayerPage({
    super.key,
    required this.audioUrl,
    required this.duration,
  });

  @override
  State<MeditationPlayerPage> createState() => _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends State<MeditationPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late Duration _sessionDuration; // límite elegido

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Definir la duración de la sesión en minutos según el popup
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

      // cortar al llegar al límite de sesión
      if (p >= _sessionDuration) {
        _stopSession();
      }
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

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text("Session Complete",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "Your meditation session has ended.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // cerrar dialog
                Navigator.pop(context); // volver atrás
              },
              child: const Text("OK",
                  style: TextStyle(color: Color(0xFFCBFBC7))),
            )
          ],
        ),
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
        title: const Text("Meditation Player"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen tipo portada
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

            // Barra de progreso
            Slider(
              activeColor: const Color(0xFFCBFBC7),
              inactiveColor: Colors.white24,
              value: _position.inSeconds.toDouble(),
              max: _sessionDuration.inSeconds.toDouble(),
              onChanged: (value) async {
                final pos = Duration(seconds: value.toInt());
                await _audioPlayer.seek(pos);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position),
                    style: const TextStyle(color: Colors.white70)),
                Text(_formatTime(_sessionDuration),
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 30),

            // Botón play/pause
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
