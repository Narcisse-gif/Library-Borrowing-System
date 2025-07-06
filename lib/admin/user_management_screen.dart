import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final fetchedUsers = await AdminService.getUsers();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  List<dynamic> get filteredUsers {
    return users.where((u) {
      final name = u['name']?.toLowerCase() ?? '';
      final email = u['email']?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("User Management"),
        backgroundColor: Colors.blueGrey.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUsers,
            tooltip: "Refresh",
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            color: Colors.blueGrey.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.blueGrey.shade600,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => query = val),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchUsers,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    tileColor: Colors.grey[100],
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        user['name'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(user['email']),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user['role']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user['role'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.indigo;
      case 'student':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
