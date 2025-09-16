import 'package:flutter/material.dart';
import 'meditation_player.dart';

class DurationPopup extends StatefulWidget {
  const DurationPopup({super.key});

  @override
  State<DurationPopup> createState() => _DurationPopupState();
}

class _DurationPopupState extends State<DurationPopup> {
  int _selectedIndex = 1; // Default 20 minutes

  final List<Map<String, String>> durations = [
    {"label": "15 minutes", "subtitle": "Quick Session"},
    {"label": "20 minutes", "subtitle": "Standard Session"},
    {"label": "30 minutes", "subtitle": "Deep Session"},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Duration",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Options
            Column(
              children: durations.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? const Color(0xFFCBFBC7)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["label"]!,
                                style: TextStyle(
                                  color: _selectedIndex == index
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )),
                            const SizedBox(height: 4),
                            Text(item["subtitle"]!,
                                style: TextStyle(
                                  color: _selectedIndex == index
                                      ? Colors.black87
                                      : Colors.white70,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                        Icon(
                          _selectedIndex == index
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _selectedIndex == index
                              ? Colors.black
                              : Colors.white70,
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCBFBC7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MeditationPlayerPage(
                              duration: durations[_selectedIndex]["label"]!,
                            )),
                  );
                },
                child: const Text(
                  "Start Meditation",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
