import 'package:flutter/material.dart';

class AfterMeditationPopup extends StatefulWidget {
  @override
  State<AfterMeditationPopup> createState() => _AfterMeditationPopupState();
}

class _AfterMeditationPopupState extends State<AfterMeditationPopup> {
  double _moodValue = 1;
  final TextEditingController _gratitudeController = TextEditingController();

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite,
                  size: 48, color: Color(0xFFCBFBC7)),
              const SizedBox(height: 16),
              const Text("Meditation Complete",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Take a moment to reflect",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),

              // Mood slider
              const Text("How are you feeling?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Slider(
                value: _moodValue,
                min: 0,
                max: 2,
                divisions: 2,
                activeColor: const Color(0xFFCBFBC7),
                inactiveColor: Colors.white24,
                onChanged: (val) => setState(() => _moodValue = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Struggling",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("Content",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("Ecstatic",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 20),

              // Gratitude
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("What are you grateful for?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _gratitudeController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Share what you're grateful for today...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBFBC7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    // TODO: save reflection to Supabase
                    Navigator.pop(context);
                  },
                  child: const Text("Save Reflection",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Skip for now",
                    style: TextStyle(color: Colors.white70)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
