import 'package:flutter/material.dart'; 
import 'nav.dart';
import 'team_dashboard.dart';
import 'today_page.dart';
import 'journey_page.dart';
import 'live_home.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});

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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildTeamCard(
                      context,
                      "Zen Warriors",
                      "Getting together to become the greatest zen warriors ever!",
                      "12 members",
                      "assets/images/team1.png",
                    ),
                    _buildTeamCard(
                      context,
                      "Mindful Family",
                      "Just want to be mindful all together, so we can all practice meditation.",
                      "8 members",
                      "assets/images/team2.png",
                    ),
                    _buildTeamCard(
                      context,
                      "SUCO Internal",
                      "The company team for the SUCO employees. Let’s get zen.",
                      "15 members",
                      "assets/images/team3.png",
                    ),
                  ],
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
    String title,
    String subtitle,
    String members,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeamDashboardPage()),
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
                  Text(members,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
