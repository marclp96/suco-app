import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPrivate = false;
  int _maxMembers = 10;
  bool _loading = false;
  String? _error;
  String? _inviteLink;

  Future<void> _createTeam() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => _error = "You must be logged in.");
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = "Team name cannot be empty.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1️⃣ Crear el team
      final response = await supabase.from('teams').insert({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'created_by': user.id,
        'is_private': _isPrivate,
        'max_members': _maxMembers,
      }).select();

      final teamId = response[0]['id'] as String;

      // 2️⃣ Insertar al creador en team_members como owner
      await supabase.from('team_members').insert({
        'team_id': teamId,
        'user_id': user.id,
        'role': 'owner',
      });

      // 3️⃣ Generar invite link seguro (fix aplicado)
      final inviteLink = "https://sucosessions.com/join/$teamId";

      setState(() {
        _inviteLink = inviteLink;
      });
    } catch (e) {
      setState(() => _error = "Error creating team: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _copyLink() {
    if (_inviteLink != null) {
      Clipboard.setData(ClipboardData(text: _inviteLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invite link copied to clipboard")),
      );
    }
  }

  void _showQrCode() {
    if (_inviteLink == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Team QR Code", style: TextStyle(color: Colors.white)),
        content: QrImageView(
          data: _inviteLink!,
          version: QrVersions.auto,
          size: 200,
          foregroundColor: Colors.white,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Create Team", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Team Name",
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
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Description",
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
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isPrivate,
                onChanged: (val) => setState(() => _isPrivate = val),
                activeColor: const Color(0xFFCBFBC7),
                title: const Text("Private Team",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Max members:",
                      style: TextStyle(color: Colors.white)),
                  DropdownButton<int>(
                    value: _maxMembers,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    items: [5, 10, 15, 20].map((val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(val.toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _maxMembers = val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBFBC7),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Create Team",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Bloque de invitación (solo si ya hay link)
              if (_inviteLink != null) ...[
                const Text("Invite Link",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_inviteLink!,
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white70),
                        onPressed: _copyLink,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _copyLink,
                      icon: const Icon(Icons.share, color: Colors.black),
                      label: const Text("Share"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBFBC7),
                        foregroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showQrCode,
                      icon: const Icon(Icons.qr_code, color: Colors.black),
                      label: const Text("QR Code"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBFBC7),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
