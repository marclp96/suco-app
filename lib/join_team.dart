import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'team_dashboard.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final TextEditingController _inviteController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _joinTeam() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => _error = "You must be logged in to join a team.");
      return;
    }

    final inviteCode = _inviteController.text.trim();
    if (inviteCode.isEmpty) {
      setState(() => _error = "Please enter an invite link.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 👇 Aquí suponemos que el inviteLink es algo como: sucosessions.com/join/<teamId>
      final teamId = inviteCode.split("/").last;

      // 1️⃣ Buscar el equipo para sacar el nombre
      final team = await supabase
          .from('teams')
          .select('id, name')
          .eq('id', teamId)
          .maybeSingle();

      if (team == null) {
        setState(() {
          _loading = false;
          _error = "Invalid invite link.";
        });
        return;
      }

      // 2️⃣ Insertar al usuario en team_members si no está ya
      await supabase.from('team_members').upsert({
        'team_id': team['id'],
        'user_id': user.id,
        'role': 'member',
      });

      // 3️⃣ Navegar al dashboard pasando id + name
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TeamDashboardPage(
            teamId: team['id'],
            teamName: team['name'],
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = "Error joining team: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Join Team",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Invite Link",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inviteController,
              decoration: InputDecoration(
                hintText: "sucosessions.com/join/abc123",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _joinTeam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCBFBC7),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Join Team",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
