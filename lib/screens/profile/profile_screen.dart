import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    setState(() {
      _imagePath = path;
    });
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    // Navigator will be handled in build if user becomes null
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Column(
        children: [
          // HEADER
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
            width: double.infinity,
            child: Column(
              children: [
                // Edit Profile Button
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile').then((_) {
                        _loadProfileImage();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  backgroundImage: (_imagePath != null && File(_imagePath!).existsSync())
                      ? FileImage(File(_imagePath!))
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // OPTIONS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTileWithValue(Icons.lock_outline, "Password", "••••••••", () {
                  Navigator.pushNamed(context, '/change-password');
                }),
                _buildTileWithValue(Icons.email_outlined, "Email Address", user.email, () {}),
                _buildTile(Icons.support_agent, "Support", () {
                  // Support action
                }),
                _buildTile(Icons.logout, "Sign Out", _logout, color: Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        leading: Icon(icon, color: color ?? Colors.blueAccent),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTileWithValue(IconData icon, String label, String value, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
