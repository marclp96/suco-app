import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'test_results.dart';
import 'app_drawer.dart';

class TestQuestionPage extends StatefulWidget {
  final String testId; // 👈 recibe el ID del test

  const TestQuestionPage({super.key, required this.testId});

  @override
  State<TestQuestionPage> createState() => _TestQuestionPageState();
}

class _TestQuestionPageState extends State<TestQuestionPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  String? _selectedKey;
  final Map<String, int> _answersCount = {}; // para contar keys elegidos
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final response = await supabase
        .from('test_questions')
        .select()
        .eq('test_id', widget.testId)
        .order('created_at', ascending: true);

    setState(() {
      _questions =
          response.map<Map<String, dynamic>>((q) => Map<String, dynamic>.from(q)).toList();
      _loading = false;
    });
  }

  void _nextQuestion() {
    if (_selectedKey != null) {
      // contar respuesta
      _answersCount[_selectedKey!] = (_answersCount[_selectedKey!] ?? 0) + 1;

      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedKey = null;
        });
      } else {
        // calcular resultado
        final winningKey = _answersCount.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TestResultsPage(
              testId: widget.testId,
              resultKey: winningKey,
            ),
          ),
        );
      }
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedKey = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: Text("No questions available", style: TextStyle(color: Colors.white))),
      );
    }

    final question = _questions[_currentIndex];
    final options = List<Map<String, dynamic>>.from(question['options']);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: _buildMainCard(question['question'], options),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedIconButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).pop(),
        ),
        Text(
          'Mindfulness Test',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Builder(
          builder: (context) => RoundedIconButton(
            icon: Icons.menu,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(String questionText, List<Map<String, dynamic>> options) {
    final progress = (_currentIndex + 1) / _questions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question ${_currentIndex + 1}/${_questions.length}",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ProgressBar(value: progress),
          const SizedBox(height: 20),
          Text(
            questionText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final option = options[index];
                final key = option['key'];
                final label = option['label'];
                return OptionTile(
                  label: label,
                  selected: _selectedKey == key,
                  onTap: () {
                    setState(() {
                      _selectedKey = key;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Previous',
            onTap: _previousQuestion,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: _currentIndex == _questions.length - 1 ? 'Finish' : 'Next',
            onTap: _nextQuestion,
          ),
        ),
      ],
    );
  }
}

// ⬇️ Reutilizamos tus componentes previos (RoundedIconButton, ProgressBar, OptionTile, PrimaryButton, SecondaryButton)

class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoundedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF333333),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value;

  const ProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF404040),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCBFBC7),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A2A2A) : const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(24),
        border: selected
            ? Border.all(color: const Color(0xFFCBFBC7), width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: const Color(0xFFCBFBC7).withOpacity(0.1),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
    return SizedBox(
      height: 64,
      child: Material(
        color: const Color(0xFFCBFBC7),
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
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
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFCBFBC7).withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFCBFBC7),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
