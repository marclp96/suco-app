import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'duration_popup.dart'; // 👈 Abre el popup antes de la meditación

class TestResultsPage extends StatefulWidget {
  final String testId;
  final List<String> resultKeys;

  const TestResultsPage({
    super.key,
    required this.testId,
    required this.resultKeys,
  });

  @override
  State<TestResultsPage> createState() => _TestResultsPageState();
}

class _TestResultsPageState extends State<TestResultsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _results = [];
  bool _loading = true;

  // IDs de las meditaciones según el tipo de resultado
  static const String meditation1Id = "f26bfa2b-6df5-4517-bf5d-fae38161321a";
  static const String meditation2Id = "e5df0b0e-0cbd-46d1-9434-e75b96ca367c";

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    // 🔹 Limitar el resultado a máximo 2 tipos
    final limitedKeys = widget.resultKeys.take(2).toList();

    final response = await supabase
        .from('test_result_types')
        .select()
        .eq('test_id', widget.testId)
        .inFilter('result_key', limitedKeys);

    setState(() {
      _results = List<Map<String, dynamic>>.from(response);
      _loading = false;
    });
  }

  /// 🔹 Guarda el resultado, asocia meditación y abre el selector de duración
  Future<void> _saveResultAndNavigate() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user logged in")),
        );
        return;
      }

      // Determinar meditación según tipo de resultado
      String? selectedMeditationId;
      if (widget.resultKeys.any((key) => ["A", "B", "C"].contains(key))) {
        selectedMeditationId = meditation1Id;
      } else if (widget.resultKeys.any((key) => ["D", "E", "F"].contains(key))) {
        selectedMeditationId = meditation2Id;
      }

      if (selectedMeditationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No matching meditation found")),
        );
        return;
      }

      // 🔹 Obtener el primer media_id real desde la meditación
      final meditationData = await supabase
          .from('meditations')
          .select('media_content')
          .eq('id', selectedMeditationId)
          .maybeSingle();

      if (meditationData == null ||
          meditationData['media_content'] == null ||
          meditationData['media_content'].isEmpty) {
        throw Exception("No media content found for meditation");
      }

      final mediaId = meditationData['media_content'][0];

      // 🔹 Buscar URL en media_versions usando el ID del media real
      final mediaVersion = await supabase
          .from('media_versions')
          .select('url')
          .eq('media_id', mediaId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final meditationUrl = mediaVersion?['url'];
      if (meditationUrl == null) {
        throw Exception("No media URL found for meditation $selectedMeditationId");
      }

      // 🔹 Guardar progreso en journey_session_log
      await supabase.from('journey_session_log').insert({
        'user_id': user.id,
        'meditation_id': selectedMeditationId,
        'completed': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 🔹 Mostrar popup de duración
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DurationPopup(audioUrl: meditationUrl),
        );
      }
    } catch (e) {
      debugPrint("❌ Error saving test result: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving result: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMix = _results.length == 2;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _results.isEmpty
                ? const Center(
                    child: Text("No results found",
                        style: TextStyle(color: Colors.white)))
                : Column(
                    children: [
                      _buildHeader(context, isMix),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildResultCard(isMix),
                              const SizedBox(height: 32),
                              _buildActionButtons(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundedIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          Text(
            isMix ? 'Your Combined Type' : 'Mindfulness Test Result',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const RoundedIconButton(
            icon: Icons.share,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(bool isMix) {
    if (!isMix) {
      final result = _results.first;
      return CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result['title'] ?? "Unknown Type",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result['description'] ?? "No description available",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    } else {
      final titles = _results.map((r) => r['title']).join(' & ');
      final descriptions = _results
          .map((r) => r['description'])
          .where((d) => d != null && d.toString().isNotEmpty)
          .join(' ');

      return CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You are a mix of $titles",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              descriptions,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Start Guided Practice',
          onTap: _saveResultAndNavigate,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const RoundedIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF333333),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFCBFBC7),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
