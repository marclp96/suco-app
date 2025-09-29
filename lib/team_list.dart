import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav.dart';
import 'team_dashboard.dart';
import 'today_page.dart';
import 'journey_page.dart';
import 'live_home.dart';
import 'create_team.dart';

final supabase = Supabase.instance.client;

class TeamListPage extends StatefulWidget {
  const TeamListPage({super.key});

  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  late Future<List<Map<String, dynamic>>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Teams",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // Botón para crear team
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateTeamPage(),
                            ),
                          );
                          // 👇 Recargamos la lista después de crear un team
                          setState(() {
                            _teamsFuture = fetchTeams();
                          });
                        },
                        icon: const Icon(Icons.add, color: Color(0xFFCBFBC7)),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _teamsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.redAccent));
                    }

                    final teams = snapshot.data ?? [];
                    if (teams.isEmpty) {
                      return const Text("No teams yet",
                          style: TextStyle(color: Colors.white70));
                    }

                    return ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final membersCount = team['team_members'] != null
                            ? (team['team_members'] as List).length
                            : 0;

                        return _buildTeamCard(
                          context,
                          team['id'],
                          team['name'],
                          team['description'] ?? '',
                          membersCount,
                          "assets/images/team1.png",
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => getPageByIndex(index)),
          );
        },
      ),
      floatingActionButton: AppCenterFAB(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    String teamId,
    String title,
    String subtitle,
    int membersCount,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDashboardPage(
              teamId: teamId,
              teamName: title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "$membersCount members",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 👇 Query para traer teams con sus miembros
Future<List<Map<String, dynamic>>> fetchTeams() async {
  try {
    final response = await supabase
        .from('teams')
        .select('id, name, description, team_members(id)'); // incluimos miembros
    print("Teams response: $response"); // 👈 debug
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("Error fetching teams: $e");
    return [];
  }
}

// función auxiliar para mapear índice del navbar a cada página
Widget getPageByIndex(int index) {
  switch (index) {
    case 0:
      return const TodayPage();
    case 1:
      return const TeamListPage();
    case 2:
      return const JourneyPage();
    case 3:
      return const LiveHomePage();
    default:
      return const TodayPage();
  }
}
