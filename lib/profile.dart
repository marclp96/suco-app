import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suco_app/team_dashboard.dart';
import 'nav.dart';
import 'today_page.dart';
import 'journey_page.dart';
import 'live_home.dart';
import 'team_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4; // 👈 Profile es el índice 4
  final supabase = Supabase.instance.client;

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const TodayPage();
        break;
      case 1:
        nextPage = const TeamListPage();
        break;
      case 2:
        nextPage = const JourneyPage();
        break;
      case 3:
        nextPage = const LiveHomePage();
        break;
      case 4:
      default:
        nextPage = const ProfilePage();
    }

    // 🔹 Usamos push con then() para refrescar al volver
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    ).then((_) {
      setState(() {}); // 🔁 Refresca estadísticas y datos al volver
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            _buildUserCard(),
            _buildJourneyStats(),
            _buildMoodCalendar(),
            _buildAchievements(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
      floatingActionButton: AppCenterFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ).then((_) => setState(() {}));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Text(
        "Profile",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ Usuario real desde Supabase
  Widget _buildUserCard() {
    final user = supabase.auth.currentUser;

    return FutureBuilder(
      future: supabase
          .from('profiles')
          .select('full_name, email, avatar_url, created_at')
          .eq('id', user!.id)
          .maybeSingle(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _errorCard("⚠️ Could not load profile info.");
        }

        final data = snapshot.data as Map<String, dynamic>;
        final fullName = data['full_name'] ?? 'User';
        final email = data['email'] ?? user.email ?? '';
        final avatarUrl =
            data['avatar_url'] ??
                'https://cdn-icons-png.flaticon.com/512/1077/1077012.png';
        final createdAt = DateTime.tryParse(data['created_at'] ?? '');
        final mindfulSince = createdAt != null
            ? "${_getMonthName(createdAt.month)} ${createdAt.year}"
            : "—";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Mindful since $mindfulSince",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Journey Stats reales desde journey_session_log
  Widget _buildJourneyStats() {
    final user = supabase.auth.currentUser;

    return FutureBuilder(
      key: UniqueKey(), // 👈 fuerza reconstrucción tras volver
      future: supabase
          .from('journey_session_log')
          .select('duration')
          .eq('user_id', user!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (snapshot.hasError) {
          return _errorCard("Could not load journey stats.");
        }

        final sessions = (snapshot.data ?? []) as List;
        final totalSessions = sessions.length;
        final totalMinutes = sessions.fold<int>(
          0,
          (sum, e) => sum + ((e['duration'] ?? 0) as num).toInt(),
        );

        final totalHours = (totalMinutes / 60).toStringAsFixed(1);
        final avgDuration = totalSessions > 0
            ? (totalMinutes / totalSessions).toStringAsFixed(0)
            : "0";

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Journey",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.people, "Sessions", "$totalSessions"),
                  _buildStatItem(Icons.access_time, "Time", "${totalHours}h"),
                  _buildStatItem(Icons.calendar_today, "Month",
                      DateTime.now().month.toString()),
                  _buildStatItem(Icons.trending_up, "Average",
                      "$avgDuration min"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFCBFBC7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // 🔹 Mood Calendar real desde emotion_logs
  Widget _buildMoodCalendar() {
    final user = supabase.auth.currentUser;

    return FutureBuilder(
      future: supabase
          .from('emotion_logs')
          .select('emotion, created_at')
          .eq('user_id', user!.id)
          .order('created_at', ascending: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (snapshot.hasError) {
          return _errorCard("Could not load mood data.");
        }

        final data = (snapshot.data ?? []) as List;
        if (data.isEmpty) {
          return _errorCard("No mood data yet. Start meditating");
        }

        final Map<int, String> moodsByDay = {};
        for (var e in data) {
          final date = DateTime.tryParse(e['created_at']);
          if (date != null) {
            moodsByDay[date.day] = e['emotion'];
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mood Calendar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.chevron_left, color: Colors.white70),
                        Text(
                          "${_getMonthName(DateTime.now().month)} ${DateTime.now().year}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final mood = moodsByDay[day];
                        return Container(
                          decoration: BoxDecoration(
                            color: _moodColor(mood),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _MoodLegend("Great", Colors.greenAccent),
                        _MoodLegend("Good", Colors.yellow),
                        _MoodLegend("Okay", Colors.orange),
                        _MoodLegend("Low", Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loadingCard() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            const Center(child: CircularProgressIndicator(color: Color(0xFFCBFBC7))),
      );

  Widget _errorCard(String message) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white70)),
      );

  static Color _moodColor(String? mood) {
    switch (mood) {
      case "Great":
        return Colors.greenAccent;
      case "Good":
        return Colors.yellow;
      case "Okay":
        return Colors.orange;
      case "Low":
        return Colors.redAccent;
      default:
        return Colors.grey[800]!;
    }
  }

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  // 🔹 Achievements reales desde achievements
  Widget _buildAchievements() {
    return FutureBuilder(
      future: supabase
          .from('achievements')
          .select('title, description, icon_url, created_at')
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (snapshot.hasError) {
          return _errorCard("Could not load achievements.");
        }

        final achievements = (snapshot.data ?? []) as List;
        if (achievements.isEmpty) {
          return _errorCard("No achievements yet. Keep meditating");
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Achievements",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: achievements.map((a) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        if (a["icon_url"] != null)
                          Image.network(
                            a["icon_url"],
                            width: 28,
                            height: 28,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a["title"] ?? "Untitled",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                a["description"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
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
        );
      },
    );
  }
}

class _MoodLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _MoodLegend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
