import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import real pages
import 'favorites.dart';
import 'auth_page.dart'; // 👈 Para redirigir tras logout

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    // 👇 Nombre y email desde Supabase
    final name = user?.userMetadata?['name'] ?? "User";
    final email = user?.email ?? "";

    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF1A1A1A),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage("assets/images/user.jpg"),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.favorite_border,
                    "Favorites",
                    onTap: () => _navigate(context, const FavoritesPage()),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications_none,
                    "Notifications",
                    trailing: _buildBadge("02"),
                    onTap: () => _navigate(
                      context,
                      const PlaceholderPage(title: "Notifications"),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.groups_outlined,
                    "Teams",
                    onTap: () => _navigate(
                      context,
                      const PlaceholderPage(title: "Teams"),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.book_outlined,
                    "Journal",
                    onTap: () => _navigate(
                      context,
                      const PlaceholderPage(title: "Journal"),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.settings_outlined,
                    "Settings",
                    onTap: () => _navigate(
                      context,
                      const PlaceholderPage(title: "Settings"),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline,
                    "Help & Support",
                    onTap: () => _navigate(
                      context,
                      const PlaceholderPage(title: "Help & Support"),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.workspace_premium_outlined,
                    "Upgrade to Premium",
                    onTap: () => _navigate(
                      context,
                      const PlaceholderPage(title: "Upgrade to Premium"),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCBFBC7),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFCBFBC7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// 👇 Placeholder temporal para páginas aún no listas
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(title),
      ),
      body: Center(
        child: Text(
          "$title Page (coming soon)",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
