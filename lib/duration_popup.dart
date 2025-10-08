import 'package:flutter/material.dart';
import 'meditation_player.dart';

class DurationPopup extends StatefulWidget {
  final String audioUrl;
  final String? meditationId; // 👈 Añadido

  const DurationPopup({
    super.key,
    required this.audioUrl,
    this.meditationId, // 👈 Añadido
  });

  @override
  State<DurationPopup> createState() => _DurationPopupState();
}

class _DurationPopupState extends State<DurationPopup> {
  String _selectedDuration = "20 min";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Duration",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDurationOption("15 min"),
            _buildDurationOption("20 min"),
            _buildDurationOption("30 min"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCBFBC7),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el popup
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeditationPlayerPage(
                      audioUrl: widget.audioUrl,
                      duration: _selectedDuration,
                      meditationId: widget.meditationId, // 👈 Pasamos el ID real
                    ),
                  ),
                );
              },
              child: const Text(
                "Start Meditation",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(String value) {
    final selected = _selectedDuration == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFCBFBC7) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: Colors.black)
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
