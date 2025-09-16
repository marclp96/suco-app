import 'package:flutter/material.dart';
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
        nextPage = const ProfilePage();
        break;
      default:
        nextPage = const TodayPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
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

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/sucolive.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Marc López",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Mindful since June 2025",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text(
                      "7 Day streak",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStats() {
    final List<Map<String, dynamic>> stats = [
      {"label": "Sessions", "value": "247", "icon": Icons.people},
      {"label": "Time", "value": "52h", "icon": Icons.access_time},
      {"label": "Month", "value": "18", "icon": Icons.calendar_today},
      {"label": "Average", "value": "12", "icon": Icons.trending_up},
    ];

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
            children: stats.map((s) {
              return Column(
                children: [
                  Icon(s["icon"] as IconData,
                      color: const Color(0xFFCBFBC7), size: 20),
                  const SizedBox(height: 6),
                  Text(
                    s["value"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    s["label"] as String,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCalendar() {
    final moods = {
      "1": "Okay",
      "2": "Good",
      "3": "Okay",
      "4": "Good",
      "5": "Great",
      "6": "Low",
      "7": "Great",
      "8": "Good",
      "9": "Low",
    };

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
                  children: const [
                    Icon(Icons.chevron_left, color: Colors.white70),
                    Text("January 2025",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, color: Colors.white70),
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
                    final day = (index + 1).toString();
                    final mood = moods[day];
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
  }

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

  Widget _buildAchievements() {
    final List<Map<String, dynamic>> achievements = [
      {
        "title": "Morning Warrior",
        "subtitle": "30 days of morning meditation",
        "icon": Icons.local_fire_department,
        "done": true,
        "progress": null,
      },
      {
        "title": "Consistency Master",
        "subtitle": "7-day meditation streak",
        "icon": Icons.repeat,
        "done": true,
        "progress": null,
      },
      {
        "title": "Time Master",
        "subtitle": "Complete 100 hours of meditation",
        "icon": Icons.access_time,
        "done": false,
        "progress": 0.5,
      },
      {
        "title": "Mindful Explorer",
        "subtitle": "Try 5 different meditation types",
        "icon": Icons.star_border,
        "done": false,
        "progress": 0.3,
      },
    ];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(a["icon"] as IconData,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a["title"] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                a["subtitle"] as String,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (a["done"] == true)
                          const Icon(Icons.check_circle,
                              color: Color(0xFFCBFBC7), size: 20),
                      ],
                    ),
                    if (a["progress"] != null) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: a["progress"] as double,
                        backgroundColor: Colors.grey[800],
                        color: const Color(0xFFCBFBC7),
                        minHeight: 6,
                      ),
                    ]
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// 👇 placeholder temporal igual que en JourneyPage
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
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
