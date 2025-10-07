import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TeamDashboardPage extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamDashboardPage({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<TeamDashboardPage> createState() => _TeamDashboardPageState();
}

class _TeamDashboardPageState extends State<TeamDashboardPage> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _recentActivity = [];
  Map<String, dynamic>? _nextSession;
  int _totalSessions = 0;
  double _totalHours = 0;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    try {
      // 1️⃣ Obtener datos básicos del equipo
      final teamResponse = await supabase
          .from('teams')
          .select('id, name, created_by')
          .eq('id', widget.teamId)
          .maybeSingle();

      final createdBy = teamResponse?['created_by'];

      // 2️⃣ Cargar miembros del equipo
      final membersResponse = await supabase
          .from('team_members')
          .select('user_id, role')
          .eq('team_id', widget.teamId);

      final members = List<Map<String, dynamic>>.from(membersResponse);

      // Si el creador del equipo no está en la lista, añadirlo como admin
      final alreadyIncluded =
          members.any((m) => m['user_id'] == createdBy);

      if (createdBy != null && !alreadyIncluded) {
        members.add({
          'user_id': createdBy,
          'role': 'admin',
        });
      }

      // 3️⃣ Cargar perfiles de los miembros
      if (members.isNotEmpty) {
        final userIds = members.map((m) => m['user_id']).toList();

        final profilesResponse = await supabase
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds);

        final profiles = List<Map<String, dynamic>>.from(profilesResponse);

        // Combinar datos de miembros con perfiles
        for (var member in members) {
          final profile = profiles.firstWhere(
            (p) => p['id'] == member['user_id'],
            orElse: () => {},
          );
          member['profiles'] = profile;
        }
      }

      final memberIds = members.map((m) => m['user_id']).toList();

      // 4️⃣ Cargar sesiones grupales (team_sessions)
      final sessionsResponse = await supabase
          .from('team_sessions')
          .select('id, meditation_id, start_time, status')
          .order('start_time', ascending: true);

      final now = DateTime.now();
      final upcoming = sessionsResponse
          .where((s) =>
              s['start_time'] != null &&
              DateTime.parse(s['start_time']).isAfter(now))
          .toList();

      Map<String, dynamic>? nextSession =
          upcoming.isNotEmpty ? upcoming.first : null;

      // 5️⃣ Cargar logs de sesiones de meditación
      List<Map<String, dynamic>> logs = [];
      if (memberIds.isNotEmpty) {
        logs = List<Map<String, dynamic>>.from(await supabase
            .from('journey_session_log')
            .select('user_id, duration, created_at')
            .inFilter('user_id', memberIds)
            .order('created_at', ascending: false)
            .limit(10));

        // Añadir nombres y avatares a cada log
        for (var log in logs) {
          final user = members.firstWhere(
              (m) => m['user_id'] == log['user_id'],
              orElse: () => {});
          if (user.isNotEmpty) {
            log['full_name'] = user['profiles']?['full_name'] ?? 'Unknown';
            log['avatar_url'] = user['profiles']?['avatar_url'];
          }
        }
      }

      // 6️⃣ Calcular estadísticas
      final totalSessions = logs.length;
      final totalMinutes = logs.fold<int>(
          0, (sum, e) => sum + ((e['duration'] ?? 0) as num).toInt());
      final totalHours = totalMinutes / 60.0;

      setState(() {
        _members = members;
        _recentActivity = logs;
        _totalSessions = totalSessions;
        _totalHours = totalHours;
        _nextSession = nextSession;
        _loading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading team dashboard: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Header con botón volver
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF333333),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            widget.teamName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon:
                              const Icon(Icons.settings, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                              icon: Icons.group,
                              label: "Sessions",
                              value: "$_totalSessions"),
                          _StatItem(
                              icon: Icons.access_time,
                              label: "Time",
                              value:
                                  "${_totalHours.toStringAsFixed(1)}h"),
                          _StatItem(
                              icon: Icons.calendar_today,
                              label: "Members",
                              value: "${_members.length}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Próxima sesión (real o placeholder)
                    const Text("Next Team Session",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _nextSession != null
                        ? _buildNextSessionCard(_nextSession!)
                        : Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                "No upcoming session yet",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    // 🔹 Banner
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            "assets/images/bg-image.jpeg",
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Meditate Together",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCBFBC7),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {},
                                child: const Text("Start Group Session"),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                onPressed: () {},
                                child: const Text("Schedule Session"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Team Members
                    const Text("Team Members",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _members.isEmpty
                        ? const Text("No members yet",
                            style: TextStyle(color: Colors.white70))
                        : Column(
                            children: _members.map((m) {
                              final profile = m['profiles'];
                              final name = profile?['full_name'] ?? "Unknown";
                              final avatar = profile?['avatar_url'];
                              final role = m['role'] ?? "member";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: avatar != null
                                          ? NetworkImage(avatar)
                                          : const AssetImage(
                                                  "assets/images/default_avatar.png")
                                              as ImageProvider,
                                      radius: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 15)),
                                          Text(role,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),

                    // 🔹 Recent Activity
                    const Text("Recent Activity",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _recentActivity.isEmpty
                        ? const Text("No recent activity yet",
                            style: TextStyle(color: Colors.white70))
                        : Column(
                            children: _recentActivity.map((a) {
                              final name = a['full_name'] ?? "Unknown";
                              final duration =
                                  (a['duration'] ?? 0).toString();
                              final avatar = a['avatar_url'];
                              final date = DateTime.tryParse(a['created_at']);
                              final formattedDate = date != null
                                  ? DateFormat('MMM d, HH:mm').format(date)
                                  : '';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: avatar != null
                                          ? NetworkImage(avatar)
                                          : const AssetImage(
                                                  "assets/images/default_avatar.png")
                                              as ImageProvider,
                                      radius: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 15)),
                                          Text(
                                              "Completed a $duration min meditation",
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14)),
                                          Text(formattedDate,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNextSessionCard(Map<String, dynamic> session) {
    final startTime = DateTime.tryParse(session['start_time'] ?? '');
    final formatted = startTime != null
        ? DateFormat("dd MMM, HH:mm").format(startTime)
        : "TBA";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.greenAccent[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Next session: $formatted",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 28),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
