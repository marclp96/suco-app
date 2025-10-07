import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AfterMeditationPopup extends StatefulWidget {
  final int duration; // minutos de la sesión

  const AfterMeditationPopup({super.key, this.duration = 15});

  @override
  State<AfterMeditationPopup> createState() => _AfterMeditationPopupState();
}

class _AfterMeditationPopupState extends State<AfterMeditationPopup> {
  double _moodValue = 1;
  final TextEditingController _gratitudeController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _saving = false;

  Future<void> _saveReflection() async {
    try {
      setState(() => _saving = true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        debugPrint("⚠️ No authenticated user found.");
        return;
      }

      // 🔹 Mapa de estado de ánimo
      final moods = ["Struggling", "Content", "Ecstatic"];
      final selectedMood = moods[_moodValue.toInt()];

      // 🔹 Guardar sesión en journey_session_log
      await supabase.from('journey_session_log').insert({
        'user_id': user.id,
        'duration': widget.duration,
        'date': DateTime.now().toIso8601String(),
        'completed': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 🔹 Guardar reflexión en reflections
      await supabase.from('reflections').insert({
        'user_id': user.id,
        'mood': selectedMood,
        'gratitude': _gratitudeController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint("✅ Meditation session and reflection saved successfully.");
      Navigator.pop(context);
    } catch (e) {
      debugPrint("❌ Error saving meditation/reflection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving reflection. Please try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

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
                  onPressed: _saving ? null : _saveReflection,
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2)
                      : const Text(
                          "Save Reflection",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
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
