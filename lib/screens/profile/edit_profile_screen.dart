import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  File? _imageFile;

  @override
  void initState() {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _passwordController = TextEditingController();
    _loadImagePath();
    super.initState();
  }

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && mounted && File(path).existsSync()) {
      setState(() => _imageFile = File(path));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', pickedFile.path);
    }
  }

  void _showPopup(BuildContext context, String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              if (isSuccess) Navigator.pop(context); // go back
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateUserProfile(
        _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
      );

      if (success) {
        _showPopup(context, "Success", "Profile updated successfully ✅", isSuccess: true);
      } else {
        _showPopup(context, "Failed", "Failed to update profile ❌", isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: (_imageFile != null && _imageFile!.existsSync())
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.blue.shade700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(user.email, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Full Name"),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email"),
                      validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("New Password (optional)"),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      fillColor: Colors.white,
      filled: true,
    );
  }
}
