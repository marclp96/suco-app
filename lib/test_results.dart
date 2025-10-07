import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'be_here_now.dart'; 

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

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final response = await supabase
        .from('test_result_types')
        .select()
        .eq('test_id', widget.testId)
        .inFilter('result_key', widget.resultKeys);

    setState(() {
      _results = List<Map<String, dynamic>>.from(response);
      _loading = false;
    });
  }

  /// resultado del test y redirige a la meditación recomendada
  Future<void> _saveResultAndNavigate() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user logged in")),
        );
        return;
      }

      // meditación Be Here Now
      final beHereNow = await supabase
          .from('meditations')
          .select('id')
          .eq('title', 'Be Here Now')
          .maybeSingle();

      // guarda resultado del test
      await supabase.from('user_test_results').insert({
        'user_id': user.id,
        'test_id': widget.testId,
        'result_key': widget.resultKeys.join(','),
        'recommended_meditation_id': beHereNow?['id'],
      });

      // Navega a la meditación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BeHereNowPage()),
      );
    } catch (e) {
      debugPrint("❌ Error saving result: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving result: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMix = widget.resultKeys.length > 1;

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
      // fusionar resultados
      final titles = _results.map((r) => r['title']).join(' and ');
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
        // SecondaryButton(
        //   text: 'View Detailed Report 👑',
        //   onTap: () {},
        // ),
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

  const RoundedIconButton({
    super.key,
    required this.icon,
    this.onTap,
  });

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

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
  });

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

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFCBFBC7),
          width: 1.5,
        ),
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
                color: Color(0xFFCBFBC7),
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
